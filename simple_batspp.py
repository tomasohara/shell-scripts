#! /usr/bin/env python
#
# BatsPP: preprocessor for bats unit test
#
# This script processes ands run custom tests using bats-core. It is based
# on example-based testing, using the output from a command as a test:
#
#   $ echo $'uno\ndos\ntres' | grep --count o
#   2
#
# NOTE: It is only necessary to have installed bats-core, In particular, there
# is no need for bats-assertions library.
#
# FYI: This version is a simplified version of the original BatsPP facility. It uses some shameless
# hacks enabled via environment variables to work around quirks in the example parsing. For example,
#   TEST_FILE=1 MATCH_SENTINELS=1 PARA_BLOCKS=1 python ./simple_batspp.py tests/adhoc-tests.test
#
# - For the regular version of BatsPP, see
#     https://github.com/LimaBD/batspp
# - For the Bats[-core] testing framework for Bash, see
#     https://github.com/bats-core/bats-core
# - Regex cheatsheet:
#     (?:regex)               non-capturing group
#     (?#comment)             comment; used below for labeling regex segments
#     *?  and  +?             non-greedy match
# - See https://www.rexegg.com/regex-quickstart.html for comprehensive cheatsheet.
# - See https://regex101.com for a tool to explain regex's.
# - See jupyter_to_batspp.py for conversion utility for Jupyter notebooks.
# - The following directives are recognized:
#     Directive              Comment
#     Continuation           Additional setup code
#     Global setup           Global setup code (e.g., alias definitions).
#     Setup                  Setup code for the test (e.g., temp. file creation)
#     Test [name]            Name to use for test instead of line number
#     Wrapup                 Optional cleanup code
# - The following environment options can be useful:
#     MATCH_SENTINELS        Wraps tests inside #Start ... # End to facilitate pattern matching.
#     PARA_BLOCKS            Tests are paragraphs delimited by blank lines
#     BASH_EVAL              Use Bash for evaluation instead of bats-core
#................................................................................
# Tips:
# - The parser is regex based so certain contructs confuse it.
# - Use separate blocks for comments following a command.
#      [ echo a; # TODO: echo b; ]   => [ echo a; ] [ # TODO: echo b; ]
#   where the brackets indicate distinct text paragraph blocks or Jupyter cells.
# - Run the Bash-formatted output through shellcheck (e.g., BASH_EVAL=1 OMIT_TRACE=1).
#................................................................................
#
## TODO1:
## - Add option to use bash-compiant syntax for tests; via https://bats-core.readthedocs.io/en/stable/gotchas.html
##     function bash_compliant_function_name_as_test_name { # @test
##         # your code
##     }
## - Issue a warning about tests with '<<END' and other arcane syntax that conflict with
##   the .bats file generation.
## - See if way to warn if empty actual output (versus expected) is likely command issue. such
##   as based on analysis of stderr. Perhaps there was a problem with aliases added to normalize output.
## - Refine diagnostics for test parsing (e.g., a la trace_pattern_match).
## TODO2:
## - Have option to save each test in a separate bats file: a simple syntax error (e.g., wrong closing quote) can cause the entire test to fail.
## - Track down source of hangup's when evaluating code with a command that gets run in background:
##   the function test-N-actual runs OK (i.e., '$ test-N-action'), but it get stuck when accessing the
##   result text (e.g., '$ result=$(test-N-actual)'.
## - Add pytest-styles directives like xfail and skip, as well as a way to flag critical tests.
## TODO3:
## - Warn if expecting command and non-comment and non-$ line encounters (e.g., Tom's funky ¢ prompt)
## - Stay in synh with Batspp:
##   https://github.com/LimaBD/batspp/tree/main/tests/cases
## - Use gh.form_path consistently (n.b., someday this might run under Window).
## - Weed out Unix-specific file path usages (e.g., f'\tcommand cp -Rp ./. "$test_folder"\n').
## TODO4:
## - Integrate features from similar utilities:
##   https://pypi.org/project/docshtest/
##   https://github.com/lehmannro/assert.sh
## TODO:
## - extend usage guide or docstring.
## - Add some directives in the test or script comments:
##        Block of commands used just to setup test and thus without output or if the output should be ignored (e.g., '# Setup').
##        Tests that should be evaluated in the same environment as the preceding code (e.g., '# Continuation'). For example, you could have multiple assertions in the same @test function.
## - find regex match excluding indent directly.
## - pretty result.
## - setup for functions tests.
## - multiline commands?.
## - solve comma sanitization, test poc [TODO: what is the issue?]:
##        $ BATCH_MODE=1 bash -i -c 'source ../tomohara-aliases.bash; mkdir -p $TMP/test-$$; cd $TMP/test-$$; touch  F1.txt F2.list F3.txt F4.list F5.txt; ls | old-count-exts'
##        .txt\t3
##        .list\t2
## - add a tag to avoid running a certain test (example "# OLD").
## - add option for runnng generated bats code through shellcheck
##   This requires that the test definitions be converted to proper bash functions:
##      perl -pe 's/^\@test "(.*)"/function $1/;' my-test.bats > my-text.bash
## - add examples below to help clarify processing

"""
BATSPP

This process and run custom tests using bats-core.

You can run tests for aliases and more using the
command line with '$ [command]' followed by the
expected output:

 $ echo -e "hello\nworld"
 hello
 world

 $ echo "this is a test" | wc -c
 15

Also you can test bash functions:
 [functions + args] => [expected]:
 fibonacci 9 => "0 1 1 2 3 5 8 13 21 34"

Simple usage:
MATCH_SENTINELS=1 PARA_BLOCKS=1 BASH_EVAL=1 {prog} xyz.batspp > xyz.log 2>&1
"""


# Standard packages
from collections import namedtuple
import os
import re
import random


# Local packages
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla      import system
from mezcla      import debug
from mezcla      import glue_helpers as gh


#-------------------------------------------------------------------------------

# Command-line labels constants
TESTFILE = 'testfile' # target test path
OUTPUT   = 'output'   # output BATS test
VERBOSE  = 'verbose'  # show verbose debug
SOURCE   = 'source'   # source another file
JUPYTER  = 'jupyter'  # run jupyter conversion (i.e., ipynb to .batspp)
FORCE    = 'force'    # run bats even if admin-like user

# Environment options
TMP = system.getenv_text("TMP", "/tmp",
                         "Temporary directory")
TEMP_DIR_DEFAULT = (gh.TEMP_BASE or gh.form_path(TMP, f"batspp-{os.getpid()}"))
TEMP_DIR =  system.getenv_text("TEMP_DIR", TEMP_DIR_DEFAULT,
                               "Temporary directory to use for tests")
EVAL_LOG = system.getenv_value("EVAL_LOG", None,
                               "Override for temp-file based evaluation log file")
COPY_DIR = system.getenv_bool("COPY_DIR", False,
                              "Copy current directory to temp. dir for input files, etc.")
FORCE_RUN = system.getenv_bool("FORCE_RUN", False,
                               "Force execution of the run even if admin-like user, etc.")
# Options to work around quirks with Batspp
PREPROCESS_BATSPP = system.getenv_bool("PREPROCESS_BATSPP", False,
                                       "Preprocess .batspp format file, removing line continuations")
MATCH_SENTINELS = system.getenv_bool("MATCH_SENTINELS", False,
                                     "Include test comment header and trailer in match")
PARA_BLOCKS = system.getenv_bool("PARA_BLOCKS", False,
                                 "Test definitions within perl-style paragraphs--\n\n ends")
# Other useful options
TRACE_MATCHING = system.getenv_bool("TRACE_MATCHING", False,
                                    "Trace out test matching for text")
RANDOM_ID = system.getenv_bool("RANDOM_ID", False,
                               "Use random ID's for tests")
OMIT_PATH = system.getenv_bool("OMIT_PATH", False,
                               "Omit PATH spec. for directory of .Batspp file")
BATS_OPTIONS = system.getenv_text("BATS_OPTIONS", " ",
                                  "Options for bats command such as --pretty")
SKIP_BATS = system.getenv_bool("SKIP_BATS", False,
                               "Do not run the bats test script")
OMIT_TRACE = system.getenv_bool("OMIT_TRACE", False,
                                "Omit actual/expected trace from bats file")
OMIT_MISC = system.getenv_bool("OMIT_MISC", False,
                               "Omit miscellaenous/obsolete bats stuff such as diagnostic code in test")
TEST_FILE = system.getenv_bool("TEST_FILE", False,
                               "Treat input as example-based test file, not a bash script")
BASH_EVAL = system.getenv_bool("BASH_EVAL", False,
                               "Evaluate tests via bash rather than bats: provides quicker results and global context")
BASH_TRACE = system.getenv_bool("BASH_TRACE", False,
                               "Trace commands during test evaluation")
MAX_ESCAPED_LEN = system.getenv_int("MAX_ESCAPED_LEN", 64,
                                    "Maximum length for escaped actual vs. expected")
GLOBAL_TEST_DIR =  system.getenv_bool("GLOBAL_TEST_DIR", False,
                                      "Use single directory for tests")
KEEP_OUTER_QUOTES = system.getenv_bool("KEEP_OUTER_QUOTES", False,
                                       "Retain outer quotation characters in output")
#
# Shameless hacks
## TEST: GLOBAL_SETUP = system.getenv_text("GLOBAL_SETUP", " ",
##                                   "Global setup bash snippet")
EXTRACT_SETUP = system.getenv_bool("EXTRACT_SETUP", False,
                                   "Extract setup based on '# Setup' comment in entire match")
AUGMENT_COMMANDS = system.getenv_bool("AUGMENT_COMMANDS", False,
                                      "Add commands missing from setup or actual from entire match")
DISABLE_ALIASES = system.getenv_bool("DISABLE_ALIASES", False,
                                      "Disable alias expansion")
MERGE_CONTINUATION = system.getenv_bool("MERGE_CONTINUATION", False,
                                        "Merge function or backslash continuations in expected with actual")
IGNORE_ALL_COMMENTS = system.getenv_bool("IGNORE_ALL_COMMENTS", False,
                                         "Strip all comments from input--blocks without commands or output")
STRIP_COMMENTS = system.getenv_bool("STRIP_COMMENTS", False,
                                    "Strip comments from expected output")
ALLOW_COMMENTS = system.getenv_bool("ALLOW_COMMENTS", False,
                                    "Allow comments in expected output")
NORMALIZE_WHITESPACE = system.getenv_bool("NORMALIZE_WHITESPACE", False,
                                          "Convert non-newline whitespace to space")
IGNORE_SETUP_OUTPUT = system.getenv_bool("IGNORE_SETUP_OUTPUT", False,
                                         "Ignore output from setup, wrapup, etc. sections")
FILTER_SHELLCHECK = system.getenv_bool("FILTER_SHELLCHECK", False,
                                       description="Add shellcheck warning filters")
OLD_ACTUAL_EVAL = system.getenv_bool("OLD_ACTUAL_EVAL", False,
                                     description="Use actual output evaluation via implicit subshell")
# Flags
USE_INDENT_PATTERN = system.getenv_bool("USE_INDENT_PATTERN", False,
                                        "Use old regex for indentation")

# Some constants
## Bruno: can you explain this pattern?
INDENT_PATTERN = r'^[^\w\$\(\n\{\}]'               # note: modified in __process_tests
BATSPP_EXTENSION = '.batspp'
# Trace levels usually go from from 6 .. 9, but from 4 .. 7 for tom, tohara, etc.
USER = system.getenv_text("USER", "user",
                          "User name")
T6_DEFAULT = (6 if not USER.startswith("to") else 4)
T6 = system.getenv_int("T6", T6_DEFAULT,
                       "Trace level to use for T6")
T7 = (T6 + 1)
T8 = (T7 + 1)
T9 = (T8 + 1)

## TEMP
# pylint: disable=f-string-without-interpolation

#-------------------------------------------------------------------------------
# Utility functions

def merge_continuation(actual, expected):
    """Merge EXPECTED into ACTUAL if line continuation (e.g., function definition)
    Note: returns tuple with new actual and expected

    >>> merge_continuation(
    ...      '''
    ...          function f {
    ...      ''', 
    ...      '''
    ...            x=1
    ...          }
    ...
    ...          123
    ...      ''')
    (
      '''
         function f {
           x=1
         }
      ''', 
      '''
         123
      ''')
    """
    ## ex: merge_continuation("function g () {}\n", "123\n") => ("function g () {}\n", "123\n")  # no change
    actual_lines = actual.split("\n")
    expected_lines = expected.split("\n")

    # Check for open function definition or trailing backslash at end of actual section
    line_continuation = False
    function_continuation = False
    for s in range(len(actual_lines) - 1, -1, -1):
        actual_line = actual_lines[s]
        if re.search(r"function.*{\s*$", actual_line):
            debug.trace(T6, f"Open function definition at actual line {s + 1}: {actual_line!r}")
            function_continuation = True
            break
        if re.search(r"[^\\]\\(\n?)$", actual_line):
            ## Lorenzo: I think the string bellow was supposed to be an Fstring because {s + 1} doesn't make much sense if not
            debug.trace(T6, "Line continuation at actual line {s + 1}: {actual_line!r}")
            line_continuation = True
            break
        debug.trace(T9, f"Non-continuation at actual line {s + 1}: {actual_line!r}")

    # If during continuation, merge lines until no longer at a continuation
    for c, expected_line in enumerate(expected_lines):
        if line_continuation or function_continuation:
            debug.trace(T8, f"Merging expected line {c + 1} with actual: {expected_line!r}")
            actual_lines.append(expected_line)
            expected_lines = expected_lines[1:]
        else:
            break
        line_continuation = re.search(r"[^\\]\\(\n?)", expected_line)
        function_continuation = (function_continuation and (not re.search(r"^\s+\}", expected_line)))
        debug.trace_expr(T7, expected_line, line_continuation, function_continuation)

    # Sanity check
    new_actual = "\n".join(actual_lines)
    new_expected = "\n".join(expected_lines)
    debug.assertion((new_actual + new_expected) == (actual + expected))
    new = ("new" if (new_actual != actual) else "old")
    debug.trace(T9, f"merge_continuation({actual!r}, {expected!r})) => {new} ({new_actual!r}, {new_expected!r})")
    return (new_actual, new_expected)


def preprocess_batspp(contents):
    """Preprocess the file CONTENTS in the .batspp format (e.g., remove line continuations)
    
    >>> preprocess_batspp(r'''
    ... function fu {\
    ...   echo "fu"; \
    ... }
    ... ''')
    '''function fu { echo "fu"; }'''
    """
    # ex: preprocess_batspp('function bar { echo "bar"; }') => 'function bar { echo "bar"; }'   # no change
    # Note: this removes line continuations for sake of simpler parsing (e.g., avoid merge_continuation)
    debug.trace(T6, "preprocess_batspp(_)")
    ## Bruno: can you fix this regex replacement?
    ## TODO: new_contents = my_re.sub(r"^(.*[^\\])\\(\n)$", r"\1\n", contents, flags=re.MULTILINE)
    lines = contents.split("\n")
    s = 0
    while (s < len(lines)):
        line = lines[s]
        debug.trace(T7, f"checking line {s + 1}: {line}")
        if ((line is not None) and line.endswith("\\") and (len(line) > 1) and (line[-2] != "\\") and (s < len(lines))):
            debug.trace(T6, f"joining lines {s + 1} and {s + 2}")
            lines[s] = line[:-1] + lines[s + 1]
            for j in range(s + 1, len(lines) - 1): 
                lines[j] = lines[j + 1]
            lines[-1] = None
        else:
            s += 1
    new_contents = "\n".join(l for l in lines if (l is not None))
    new = ("new" if (new_contents != contents) else "old")
    debug.trace(T8, f"preprocess_batspp({contents!r}) => {new} {new_contents!r}")
    debug.trace(T8, f"\tlen(c)={len(contents)}; len(nc)={len(new_contents)}")
    debug.assertion(len(new_contents) <= len(contents))
    return new_contents

#-------------------------------------------------------------------------------

TEST_FIELD_NAMES = ["entire", "title", "setup", "actual", "expected"]

TestFieldTypes = namedtuple("TestFieldTypes", TEST_FIELD_NAMES)

                                                
class Batspp(Main):
    """This process and run custom tests using bats-core"""


    # Class-level member variables for arguments (avoids need for class constructor)
    testfile     = ''
    output       = ''
    source       = ''
    verbose      = False
    force        = FORCE_RUN
    jupyter      = False


    # Global States
    is_test_file = None
    file_content = ''
    eval_prog = ("bats" if not BASH_EVAL else "bash")
    bats_content = f'#!/usr/bin/env {eval_prog}\n\n'
    if BASH_TRACE:
        bats_content += "# enable command tracing\nset -o xtrace\n\n"

    def setup(self):
        """Process arguments"""

        # Check the command-line options
        self.testfile     = self.get_parsed_argument(TESTFILE, "")
        self.output       = self.get_parsed_argument(OUTPUT, "")
        self.source       = self.get_parsed_argument(SOURCE, "")
        self.jupyter      = self.get_parsed_option(JUPYTER, self.jupyter)
        self.force        = self.get_parsed_option(FORCE, self.force)
        self.verbose      = self.get_parsed_option(VERBOSE, system.getenv_bool("VERBOSE"))

        debug.trace(T7, (f'batspp - testfile: {self.testfile}, '
                         f'output: {self.output}, '
                         f'source: {self.source}, '
                         f'force: {self.force}, '
                         f'jupyter: {self.jupyter}, '
                         f'verbose: {self.verbose}'))
        debug.trace_object(T8, self, label=f"{self.__class__.__name__} instance")


    def run_main_step(self):
        """Process main script"""
        # TODO4: remove temp files unless debugging
        debug.trace_object(T7, f"{self.__class__.__name__}.run_main_step()")

        # Optionally convert Jupyter notebook (.ipynb) to BatsPP file (.batspp)
        if self.jupyter:
            debug.assertion(self.testfile.endswith("ipynb"))
            temp_batspp_file = self.temp_file + BATSPP_EXTENSION
            log_file = temp_batspp_file + ".log"
            gh.run(f"jupyter_to_batspp.py --output '{temp_batspp_file}' '{self.testfile}' 2> {log_file}")
            ## DEBUG (tracking down TEMP_FILE issue):
            ## gh.run(f"cp -v {temp_batspp_file} /tmp")
            ## debug.assertion(system.file_exists(gh.form_path("/tmp", gh.basename(temp_batspp_file, temp_batspp_file))))
            self.testfile = temp_batspp_file
        
        # Check if is test of shell script file
        self.is_test_file = (TEST_FILE or self.testfile.endswith(BATSPP_EXTENSION))
        debug.trace(T7, f'batspp - {self.testfile} is a test file (not shell script): {self.is_test_file}')
        ## TODO: debug.assertion(self.is_test_file == Batspp.is_test_file)
        debug.assertion(self.is_test_file == Batspp.is_test_file, assert_level=T8)
        # TEMP: make sure global same as instance
        Batspp.is_test_file = self.is_test_file

        # Read file content
        self.file_content = system.read_file(self.testfile)
        if (self.is_test_file and PREPROCESS_BATSPP):
            self.file_content = preprocess_batspp(self.file_content)

        # Check if ends with newline
        if not self.file_content.endswith('\n\n'):
            self.file_content += '\n'


        self.__process_setup()
        self.__process_teardown()
        self.__process_tests()


        # Set Bats filename
        if self.output:
            batsfile = self.output
            if batsfile.endswith('/'):
                ## TODO: fixme (e.g., filename '##.batspp')-- ex via glue_helpers.remove_extension
                name = re.search(r"\/(\w+)\.", batsfile).group(0)
                batsfile += f'{name}.bats'
        else:
            batsfile = self.temp_file


        # Save Bats file
        system.write_file(batsfile, self.bats_content)


        # Add execution permission to directly run the result test file
        if self.output:
            gh.run(f'chmod +x {batsfile}')


        # Run unless adminstrative user and --force not 
        skip_bats = SKIP_BATS
        if not skip_bats:
            is_admin = my_re.search(r"root|admin|adm", gh.run("groups"))
            if is_admin:
                if not self.force:
                    system.exit("Error: running bats under admin-like account requires --{force} option", force=FORCE)
                system.print_error("FYI: not recommended to run under admin-like account (to avoid inadvertant deletions, etc..)")
    
            
        if not SKIP_BATS:
            ## TODO2: include time out to account for hanging tests
            debug.trace(T7, f'batspp - running test {self.temp_file}')
            debug.assertion(not (BASH_EVAL and BATS_OPTIONS.strip()))
            eval_prog = ("bats" if not BASH_EVAL else "bash")
            # note: uses empty stdin in case of buggy tests (to avoid hangup);
            # uses .eval.log to avoid conflict with batspp_report.py
            eval_log = (EVAL_LOG if EVAL_LOG else (self.temp_file + ".eval.log"))
            bats_output = gh.run(f'{eval_prog} {BATS_OPTIONS} {batsfile} < /dev/null 2> {eval_log}')
            print(bats_output)
            system.print_stderr(debug.call(4, gh.run, f"check_errors.perl {eval_log}") or "")
            debug.assertion(not my_re.search(r"^0 tests", bats_output, re.MULTILINE))


    def __process_setup(self):
        """Process tests setup"""
        debug.trace(T7, f'batspp - processing setup')


        # NOTE: files are loaded globally to
        #       to avoid problems with functions
        #       commands.


        # Make executables ./tests/../ visible to PATH
        #
        # This is usefull then the file is specially for testing.
        #
        # The structure should be:
        #  project
        #     ├ script.bash
        #  	  └ tests/test_script.batspp
        if not OMIT_PATH:
            self.bats_content += ('# Make executables ./tests/../ visible to PATH\n'
                                  f'PATH="{gh.dir_path(gh.real_path(self.testfile))}/../:$PATH"\n\n')

        # Enable aliases unless explicitly disabled
        enable_aliases = (not DISABLE_ALIASES)
        if not enable_aliases:
            all_content = (self.file_content + (system.read_file(self.source) if self.source else ""))
            debug.assertion(re.search(r"(alias \S+ =)|(function \S+ \(\) \{)", all_content, flags=my_re.VERBOSE))
        if enable_aliases:
            self.bats_content += ('# Enable aliases\n'
                                  'shopt -s expand_aliases\n\n')
            

        # Source Files
        # Notes: This is used to enable aliases globally. Unfortunately, it gets reloaded for each test
        # and can take a long time to run under bats-core, which can be slow to begin with (e.g., each
        # test gets run in a separate process).
        # See https://bats-core.readthedocs.io/en/stable/faq.html#how-can-i-include-my-own-sh-files-for-testing.
        # - The setup_file function mentioned there is not helpful as that doesn't allow for aliases.
        if (self.source or (not self.is_test_file)):
            self.bats_content += ('# Source files\n')
            num_sourced = 0

            if not self.is_test_file:
                self.bats_content += f'source {gh.real_path(self.testfile)} || true\n'
                num_sourced += 1

            if self.source:
                self.bats_content += f'source {gh.real_path(self.source)} || true\n'
                num_sourced += 1

            if num_sourced:
                self.bats_content += '\n'

        # Global variables
        if IGNORE_SETUP_OUTPUT:
            self.bats_content += ("# Global bookkeeping variables\n" +
                                  "test_output_ignored=0\n" +
                                  "num_ignored_tests=0\n" +
                                  "\n")

        # Miscellaneous stuff
        if FILTER_SHELLCHECK:
            self.bats_content += ("# Code linting support\n" +
                                  "# Selectively ignores following shellcheck warnings:\n" +
                                  "#   SC2016: Expressions don't expand in single quotes\n" +
                                  "#   SC2028: echo may not expand escape sequences\n" +
                                  "\n")
            
    # pylint: disable=no-self-use
    def __process_teardown(self):
        """Process teardown"""
        debug.trace(T7, f'batspp - processing teardown')
        # WORK-IN-PROGRESS


    def __process_tests(self):
        """Process tests"""
        debug.trace(T7, f'batspp - processing tests')

        # Tests with simple indentation (i.e. #) are ignored on batspp files.
        # Tests with double indentation (i.e. ##) are ignored on shell scripts.
        global INDENT_PATTERN
        if self.is_test_file:
            ## Note: The {0} causes the following indent pattern to be ignored:
            ##   [^\w\$\(\n\{\}]
            INDENT_PATTERN += r'{0}'
            ## TODO: INDENT_PATTERN += "[^#]"
        else:
            INDENT_PATTERN += r'?'
        INDENT_PATTERN += r'\s*'

        command_tests  = CommandTests(verbose_debug=self.verbose)
        function_tests = FunctionTests(verbose_debug=self.verbose)
        # TODO: add is_test_file to constructor; simplify class inter-dependencies
        command_tests.is_test_file = self.is_test_file
        function_tests.is_test_file = self.is_test_file

        # Do the test extraction, optionally removing regular content from bash scripts (i.e., extract comments and empty lines)
        file_content = self.file_content
        JUST_COMMENTS = system.getenv_bool("JUST_COMMENTS", (not self.is_test_file),
                                           "Strip non-comments from bash input")
        if JUST_COMMENTS:
            # Note: This simplifies pattern matching for text extraction, such as in helping
            # to avoid the expected output field from incorporating extraneous content.
            # TODO: allow for here-documents with comments and other special cases
            file_content = ""
            for line in self.file_content.splitlines():
                if not my_re.search("^[^#].*$", line):
                    file_content += line + "\n"
            debug.trace(T8, f"content after non-comment stripping:\n\t{file_content!r}")
            system.write_file(gh.form_path(TMP, "file_content.list"), file_content)
        #
        all_test_ids = []
        content, ids = command_tests.get_bats_tests(file_content)
        self.bats_content += content
        all_test_ids += ids
        
        if not self.is_test_file:
            # TODO: sort combined set of tests based on file offset to make order more intuitive
            content, ids = function_tests.get_bats_tests(file_content)
            self.bats_content += content
            all_test_ids += ids

        # Generate optional code to evaluate tests directly via Bash
        if BASH_EVAL:
            self.bats_content += 'n=0\nbad=0\n'
            self.bats_content += (
                'function run-test {\n' +
                '    local id="$1"\n' +
                ('    echo Running test "$id"\n' if BASH_TRACE else '') +
                '    let n++\n' +
                '    result="ok"\n' +
                '    eval "$id"; if [ $? -ne 0 ]; then let bad++; result="not ok"; fi\n' +
                '    echo "$result $n $id"\n' +
                ('    if [ "$test_output_ignored" = "1" ]; then echo test ignored; fi\n' if IGNORE_SETUP_OUTPUT else '') +
                '    }\n'
                )
            self.bats_content += f'tests=({" ".join(all_test_ids)}); echo "1..${{#tests[@]}}"\n'
            self.bats_content += 'for id in "${tests[@]}"; do run-test "$id"; done\n'
            self.bats_content += 'echo ""\n'
            ## TODO2: output num ignored (e.g., setup/wrapup code)
            ignored_spec = (', $num_ignored_tests ignored' if IGNORE_SETUP_OUTPUT else '')
            self.bats_content += f'echo "$n tests, $bad failure(s){ignored_spec}"\n'

#-------------------------------------------------------------------------------
        
# Global test number
_test_num = 0

class CustomTestsToBats:
    """Base class to extract and process tests"""

    def __init__(self, patterns, re_flags=0, verbose_debug=False):
        self._verbose       = verbose_debug
        self._re_flags      = re_flags
        assert(isinstance(patterns, list) and not isinstance(patterns, str))
        self._patterns      = None
        self._assert_equals = True
        self._setup_funct   = None
        self._test_id       = self.next_id()
        self._indent_used   = None
        self.is_test_file   = None
        self.num_tests      = 0

        # Add optional header and trailer patterns
        self._patterns = patterns
        if MATCH_SENTINELS:
            # notes: This matches '# Start' as well as comments before title, which is
            # done in order to capture '# Setup' comments. Uses non-greedy matches to ignore test name.
            header  =  r'(?#header   )(?:# *Start[^\n]*\n(?:#[^\n]*\n)*?)'
            ## TODO: trailer =  r'(?#trailer  )(?:# *End[^\n]*\n)'
            trailer =  r'(?#trailer  )'
            self._patterns = [header] + patterns + [trailer]
        debug.trace_object(T8, self, label=f"{self.__class__.__name__} instance")
        
    def next_id(self):
        """Return next ID for test"""
        global _test_num
        _test_num += 1
        test_id = str(random.randint(1, 999999) if RANDOM_ID else _test_num)
        debug.trace(T6, f"next_id() => {test_id}; self={self}")
        return test_id

    def _first_process(self, match):
        """First process after match, format matched results into [title, setup, actual, expected]"""

        # NOTE: this must be overriden.
        # TODO: raise NotImplementedError()
        # NOTE: the returned values must be like:
        result = TestFieldTypes._fields

        debug.trace(T7, f'batspp (test {self._test_id}) - CustomTestsToBats._first_process({match}) => {result}')
        return result

    def _preprocess_field(self, field):
        """Preprocess match result FIELD"""

        # Remove comment indicators
        field = my_re.sub(r'^\s*\#\s+(Actual|Continuation|End|Global.Setup|Setup|Start|Wrapup)\s*\n', '', field,
                          flags=re.MULTILINE|re.IGNORECASE)
            
        # Remove indent
        ## TODO?: if USE_INDENT_PATTERN and not Batspp.is_test_file:
        ## OLD:
        if not Batspp.is_test_file:
            field = my_re.sub(fr'^{self._indent_used}', '', field, flags=my_re.MULTILINE)

        return field

    def _preprocess_command(self, field):
        """Preprocess command FIELD"""
        in_field = field
        field = self._preprocess_field(field)

        # Remove comments (n.b., needs to be done after comment indicators checked)
        if STRIP_COMMENTS:
            field = my_re.sub(r'^\s*\#.*\n', '', field, flags=re.MULTILINE)
        ## TODO2: debug.trace(T8, f"_preprocess_command({in_field!r}) ==  {field!r}")
        debug.trace(5, f"_preprocess_command({in_field!r}) == {field!r}")
        
        return field

    def _preprocess_output(self, field):
        """Preprocess output FIELD"""
        in_field = field
        field = self._preprocess_field(field)
        
        # Strip whitespaces
        # TODO: make this optional for expected output field
        field = field.strip()

        # Remove comments (n.b., needs to be done after comment indicators checked
        if STRIP_COMMENTS:
            debug.trace(T6, "FYI: stripping comments in output field")
            field = my_re.sub(r'^\s*\#.*\n', '', field, flags=re.MULTILINE)
        elif (my_re.search(r'^\s*\#.*\n', field, flags=re.MULTILINE) and not ALLOW_COMMENTS):
            debug.trace(4, f"Error: comment in output field: {field!r}")
            
        # Remove initial and trailing quotes
        ## OLD: field = my_re.sub(f'^(\"|\')(.*)(\"|\')$', r'\2', field)
        if not KEEP_OUTER_QUOTES:
            field = my_re.sub(r'^(\"|\')(.*)\1$', r'\2', field)
        debug.trace(T8, f"_preprocess_output({in_field!r}) == {field!r}")
        return field

    def _common_process(self, test):
        """Common process for each field in test"""
        debug.trace(6, f'in _common_process({test!r})')
        result = []

        # Get indent used
        self._indent_used = ''
        if my_re.match(INDENT_PATTERN, test.actual):
            self._indent_used = my_re.group(0)
            debug.trace(T7, f'batspp (test {self._test_id}) - indent founded: "{self._indent_used}"')

        # Preprocess command and output fields
        ## TODO4: uses T6 instead of 5 in traces (likewise elsewhere)
        entire = test.entire
        title = test.title
        setup = self._preprocess_command(test.setup)
        debug.trace_expr(5, test.actual)
        actual = self._preprocess_command(test.actual)
        debug.trace_expr(5, actual)
        expected = self._preprocess_output(test.expected)

        result = TestFieldTypes(*[entire, title, setup, actual, expected])
        debug.trace(T7, f'batspp (test {self._test_id}) - _common_process({test!r}) => {result!r}')
        return result


    def _last_process(self, test):
        """Process test fields before convert into bats"""

        # NOTE: if this is overrided, the result must be:
        # result = ['title', 'setup', 'actual', 'expected']

        result = test

        debug.trace(T7, f'batspp (test {self._test_id}) - CustomTestsToBats._last_process({test}) => {result}')
        return result

    def _convert_to_bats(self, test):
        """Convert tests to bats format, returning test text and title"""
        entire, title, setup, actual, expected = test
        debug.trace_expr(T6, entire, title, setup, actual, expected, prefix="_convert_to_bats: ", delim="\n")
        debug.assertion(not my_re.search(r"^\$", expected, flags=re.MULTILINE),
                        f"The expected output shouldn't have $ prompt at start of line: {expected!r}")
        (actual, expected) = self.merge_continuation(actual, expected)

        # Ignore if just comments
        if IGNORE_ALL_COMMENTS:
            entire_sans_comments = my_re.sub(r"^\s*\#.*\n", "", entire, flags=re.MULTILINE)
            if not entire_sans_comments.strip():
                debug.trace(T6, f"FYI: Ignoring test that is just comments: {gh.elide(entire)!r}")
                return "", ""
        
        # Process title
        # Note: The test label starts with a number and includes optional user name (e.g, test-1-hello-world).
        title_prefix = f'test-{self._test_id}'
        if title:
            title = (title_prefix + "-" + title.replace(" ", "-"))
        else:
            title = title_prefix
        unspaced_title = my_re.sub(r'\s+', '-', title)
        # note: remove special punctuation (TODO3: retain for comments)
        unspaced_title = my_re.sub(r"([^ a-z0-9_-])", "_", unspaced_title)

        # HACK: Extract setup command from entire match if '# Setup' indicator given
        # but the setup section is empty.
        if (EXTRACT_SETUP and (not setup) and my_re.search(r"#\s*Setup\n\$([^\n]+\n)", entire,
                                                           flags=re.IGNORECASE|re.MULTILINE)):
            setup = my_re.group(1)
            debug.trace(T6, f"Using setup fallback code extracted from entire match: {setup}")
        # Similarly, get commands from entire section not present in setup nor actual
        if AUGMENT_COMMANDS:
            for command in re.findall(r"^\s*\$([^\n]+)\n", entire, flags=re.IGNORECASE|re.MULTILINE):
                if command.strip() not in (setup + actual + expected):
                    debug.trace(T6, f"Adding missing command to setup: {command}")
                    if setup and (not re.search(r"[;\}]\s*$", setup)):
                        setup += ";"
                    setup += ("\t" + command + "\n")
            debug.trace(T6, f"hacked_setup={setup!r}")

        # Process setup commands
        # Note: set COPY_DIR to copy files in current dir to temp. dir.
        ## TODO: temp_dir = Main.temp_base; put copy in setup if GLOBAL_TEST_DIR
        debug.assertion(BASH_EVAL or not GLOBAL_TEST_DIR)
        ## OLD: gh.full_mkdir(test_folder)
        self.num_tests += 1
        setup_text = ""
        if GLOBAL_TEST_DIR:
            test_folder = gh.form_path(TEMP_DIR, "global-test-dir")
        else:
            test_subdir = unspaced_title
            ## TODO1: test_folder = gh.form_path(TEMP_DIR, test_subdir)
            ## NOTE: The above is leading to odd errors after running a dozen or so tests files
            ##    '/bin/sh: 1: cannot open /dev/null: No such file'
            test_folder = gh.form_path(".", test_subdir)
            setup_text += (
                f'\ttest_folder="{test_folder}"\n' +
                f'\tmkdir --parents "$test_folder"\n' +
                (f'\tcommand cp -Rp ./. "$test_folder"\n' if COPY_DIR else "") +
                # note: warning added for sake of shellcheck
                f'\tbuiltin cd "$test_folder" || echo Warning: Unable to "cd $test_folder"\n')
        setup_sans_prompt = my_re.sub(r'^\s*\$', '\t', setup, flags=my_re.MULTILINE)
        setup_text += setup_sans_prompt + "\n"
        debug.trace_expr(T6, setup_text)

        # actual and expected
        actual_label   = 'actual'
        expected_label = 'expected' if self._assert_equals else 'not_expected'
        setup_label   = 'setup'

        # Process assertion
        assertion_text = "==" if self._assert_equals else "!="

        # Process functions
        actual_function   = f'{unspaced_title}-{actual_label}'
        actual_var = f'{actual_function}-result'.replace("-", "_")
        expected_function = f'{unspaced_title}-{expected_label}'
        expected_var = f'{expected_function}-result'.replace("-", "_")
        setup_function    = None
        functions_text    = ''
        functions_text   += self._get_bash_function(actual_function, actual)
        # Note: to minimize issues with bash syntax, a bash here-document is used (e.g., <<END\n...\nEND\n).
        # TOOO?: Use <<- variant so that leading tabs are ignored.
        # TODO: use an external file (as the @here might fail if the example uses << as well)
        # Note: The here-document delimiter is quoted to block variable interpolation
        #    https://stackoverflow.com/questions/4937792/using-variables-inside-a-bash-heredoc
        expected_output = ('\tcat <<"END_EXPECTED"\n' +
                           ((expected + "\n") if expected else "") +
                           'END_EXPECTED')
        functions_text   += self._get_bash_function(expected_function, expected_output,
                                                    output=True)

        # Add special hooks for when '# Setup' or '# Continuation' specified
        # HACK: Updates instance state to process such indicator comments (to avoid regex complication)
        # note: The regex parsing isolates "# Setup" code only when '# Actual' used, which is
        # not commonly used. (see CommandTests.__init__ for regex definition.)
        has_setup_comment = re.search(r"#\s*Setup", entire, re.IGNORECASE)
        has_wrapup_comment = re.search(r"#\s*Wrapup", entire, re.IGNORECASE)
        has_continuation_comment = re.search(r"#\s*Continuation", entire, re.IGNORECASE)
        use_setup_function = (has_setup_comment or has_continuation_comment or has_wrapup_comment or setup_text.strip())
        if use_setup_function:
            setup_function   = f'{unspaced_title}-{setup_label}'
            self._setup_funct = setup_function
            functions_text += self._get_bash_function(setup_function, setup_text)
        ## OLD:
        ## has_continuation_comment = re.search(r"#\s*Continuation", entire, re.IGNORECASE)
        ## use_setup_function = (has_setup_comment or has_continuation_comment)
        setup_call = ""
        if use_setup_function:
            debug.trace(T6, f"Using separate setup function {self._setup_funct}")
            if not self._setup_funct:
                system.print_error(f"Error: No setup function defined for test {unspaced_title}")
            else:
                setup_call = ("\t" + self._setup_funct + ";\n")
        else:
            ## TODO: self._setup_funct = None
            pass

        # Get actual and expected results
        # TODO3: use helper bash function to minimize boilerplate code
        # TODO1: add output normalization (similar to _preprocess_output)
        # Note: When evaluating the function, an evaluation context is not used so that
        # the current process state gets modified, not the implicit child process.
        # For example, 'actual=$(test-n-actual)' => 'test-n-actual > out; actual=$(cat out)'
        # See https://stackoverflow.com/questions/23564995/how-to-modify-a-global-variable-within-a-function-in-bash
        main_body = f"\tlocal {actual_var} {expected_var}\n"
        if OLD_ACTUAL_EVAL:
            main_body += f'\t{actual_var}="$({actual_function})"\n'
        else:
            out_file = gh.form_path(test_folder, f"{unspaced_title}.out")
            main_body += (
                f'\tout_file="{out_file}"\n' +
                f'\t{actual_function} >| "$out_file"\n' +
                f'\t{actual_var}="$(cat "$out_file")"\n')
            main_body += f'\t{expected_var}="$({expected_function})"\n'
        ## TODO3: just normalize actual at runtime as expected can be done ahead of time
        if NORMALIZE_WHITESPACE:
            main_body += (f'\t{actual_var}="$(normalize-whitespace \"${actual_var}\")"\n' +
                          f'\t{expected_var}="$(normalize-whitespace \"${expected_var}\")"\n')
        if STRIP_COMMENTS:
            main_body += (f'\t{actual_var}="$(strip-comments \"${actual_var}\")"\n' +
                          f'\t{expected_var}="$(strip-comments \"${expected_var}\")"\n')
        if IGNORE_SETUP_OUTPUT:
            if (has_setup_comment or has_continuation_comment or has_wrapup_comment):
                # note: setup and wrapup output ignored; however, code run above for side effects
                # TODO2: make sure success not counted in stats
                main_body += (f'\t{actual_var}=ignored\n' +
                              f'\t{expected_var}=ignored\n' +
                              '\tlet num_ignored_tests++\n' +
                              '\ttest_output_ignored=1\n')
            else:
                main_body += f'\ttest_output_ignored=0\n'
            
        # Process debug
        debug_text = ""
        if not OMIT_TRACE:
            verbose_print = '| hexview.perl' if  self._verbose else ''
            #
            def esc(text, max_len=None):
                """Escape text for printing with single quotes replaced with double
                Note: Uses string representation (repr), up to MAX_LEN characters;
                intended for bash echo inside single quoted string, which precludes use of \'
                """
                ## TODO: single quoted text with unicode prime symbol
                ## TEST: return text.replace("'", '\\"')
                ## TODO: result = repr(text).replace("'", "\u2032")         # U+2032: prime (′)
                if max_len is None:
                    max_len = MAX_ESCAPED_LEN
                result = gh.elide(repr(text).replace("'", '"'), max_len=max_len)
                debug.trace(T9, f"esc({text!r} => {result}")
                return result
            #
            # note: 'actual' here is the code, but 'expected' is the output
            debug_text = ('\techo ""\n' +
                          ('\t# shellcheck disable=SC2016,SC2028\n' if FILTER_SHELLCHECK else '') +
                          f"\techo '========== actual: {esc(actual)} =========='\n" +   
                          f'\techo "${actual_var}"\n' +
                          (f'\techo "${actual_var}" {verbose_print}\n' if self._verbose else "") +
                          ('\t# shellcheck disable=SC2016,SC2028\n' if FILTER_SHELLCHECK else '') +
                          f"\techo '========== expect: {esc(expected)} =========='\n" +
                          f'\techo "${expected_var}"\n' +
                          (f'\techo "${expected_var}" {verbose_print}\n' if self._verbose else "") +
                          '\techo "============================"\n')

        # Construct bats tests
        misc_code = ""
        if not OMIT_MISC:
            misc_code = (
                f'\t# actual {{ {actual!r} }} => "${actual_var}"\n' +
                f'\t# expect {{ {expected!r} }} => "${expected_var}"\n')
        test_header = (f'@test "{unspaced_title}"' if not BASH_EVAL else f'function {unspaced_title}')
        result = (f'{test_header} {{\n' +
                  (f'{setup_text}' if not use_setup_function else setup_call) +
                  f'{main_body}' +
                  f'{debug_text}' +
                  misc_code + 
                  f'\t[ "${actual_var}" {assertion_text} "${expected_var}" ]\n' +
                  f'}}\n\n' +
                  f'{functions_text}\n')

        debug.trace(T7, f'batspp (test {self._test_id}) - _convert_to_bats({test}) =>\n{result}')
        return result, unspaced_title

    def _get_bash_function(self, name, content, output=False):
        """Return bash function with NAME and code CONTENT, optionally for expected OUTPUT"""
        if not output:
            # Strip comments
            content = my_re.sub(r"^\s*\#[^\n]*\n", "", content, flags=re.MULTILINE)
            # Remove prompts
            content = my_re.sub(r"^\s*\$ ", "", content, flags=re.MULTILINE)
        # Make sure indented
        if not content.startswith("\t"):
            content = my_re.sub(r"^([^\t])", r"\t\1", content, flags=re.MULTILINE)
        result = (f'function {name} () {{\n' +
                  '\t# no-op in case content just a comment\n' +
                  '\ttrue\n' +
                  '\n' +
                  f'{content}\n' +
                  '}\n\n')
        debug.trace(T7, f'batspp (test {self._test_id}) - get_bash_function(name={name}, content={content}) => {result}')
        return result

    def trace_pattern_match(self, text):
        """Traces out the matching for TEXT in stages, using self._patterns one at a time. 
        This uses a greedy approximation to the regular regex matching with concatenation.
        Note: Intended just as quick-n-dirty way to debug regex evaluation
        """
        debug.trace(T6, f"trace_pattern_match({gh.elide(text, 512)!r})")
        debug.trace_expr(T7, self._re_flags)
        for p, pattern in enumerate(self._patterns):
            debug.trace(T7, f"\tp{p + 1}: {pattern}")
        # note: temporarily raises level of overly verbose regex matching
        save_my_re_TRACE_LEVEL = my_re.TRACE_LEVEL
        my_re.TRACE_LEVEL = T9
        save_INDENT0 = debug.INDENT0

        # Initialize
        start = 0
        p = 0
        num_patterns = len(self._patterns)
        matches = []

        # Do searches incrementally
        found = False
        while ((p < num_patterns) and (not found)):
            next_p = (p + 1)
            debug.INDENT0 = ("    " * (p + 1))

            # Do next search
            # Note: If text consumed, search is over dummy newline.
            pattern_spec = f"{p + 1}"
            debug.trace(T6, f"Checking pattern {pattern_spec} at offset {start}; {gh.elide(text[start:], 10)!r}")
            over_actual_text = (len(text[start:]) > 0)
            remainder = (text[start:] if over_actual_text else "\n")
            # note: subsequent patterns must start at current position (hence match not search)
            search_fn = (my_re.match if (p > 0) else my_re.search)
            found = search_fn(self._patterns[p], remainder, flags=self._re_flags)
            if not found:
                break
            start += my_re.end()
            match_text = my_re.group(0)
            matches.append(match_text if over_actual_text else f"{match_text}???")
            debug.trace(T6, f"Match for pattern {pattern_spec} at {my_re.span()}: {gh.elide(my_re.group(0), 80)!r}")
            found = (next_p == num_patterns)

            # Advance to next pattern
            p += 1
        debug.INDENT0 = ""

        # Summarize
        debug.trace_expr(T6, found)
        if found:
            debug.trace(T6, "Matching text:")
            for m in range(len(matches)):
                debug.trace(T6, f"\tp{m + 1}: {matches[m]!r}")

        # Reset temporary changes
        my_re.TRACE_LEVEL = save_my_re_TRACE_LEVEL
        debug.INDENT0 = save_INDENT0
        return

    def normalize_block(self, text):
        """Normalize TEXT for matching (e.g., adding Start/End sentinels)"""
        debug.trace(T9, f"normalize_block(_); self={self}")
        in_text = text
        debug.assertion(PARA_BLOCKS)
        if MATCH_SENTINELS:
            if not my_re.search(r"#\s*Start", text):
                text = "# Start\n" + text.lstrip("\n")
            ## TODO:
            ## if not my_re.search("#\s*End", text):
            ##     text = text.rstrip("\n") + "\n# End\n"
        debug.trace(T8, f"normalize_block({in_text!r}) => {text!r}")
        return text
    
    def get_bats_tests(self, text):
        """Returns BATS tests as string plus list of test names"""

        debug.trace(T7, f'batspp - pattern used ({self._re_flags}): {self._patterns}')

        bats_tests = ''
        test_ids = []

        # Add helper functions
        if NORMALIZE_WHITESPACE:
            ## TODO4: rework to match other code generation (e.g., not using """...""")
            tab = "\t"
            helper_code = (rf"""# Helper functions
                function normalize-whitespace {{ 
                   {tab}local text
                   {tab}text=$(echo "$*" | perl -pe "s/^\s+//;  s/[ \t]+/ /g;  s/[ \t] *$//;"); 
                   {tab}echo "$text";
                }}
                """)
            bats_tests += my_re.sub(r"^ +", "", helper_code, flags=re.MULTILINE)
            bats_tests += "\n"
        if STRIP_COMMENTS:
            tab = "\t"
            helper_code = (rf"""# Helper functions
                function strip-comments {{ 
                   {tab}local text
                   {tab}text=$(echo "$*" | perl -pe "s/^\s*\#.*\n//;"); 
                   {tab}echo "$text";
                }}
                """)
            bats_tests += my_re.sub(r"^ +", "", helper_code, flags=re.MULTILINE)
            bats_tests += "\n"
           
        
        # Add global setup if using global test dir
        if GLOBAL_TEST_DIR:
            test_folder = gh.form_path(TEMP_DIR, "global-test-dir")
            bats_tests += (
                "# Global test directory setup\n" +
                f'test_folder="{test_folder}"\n' +
                f'mkdir --parents "$test_folder"\n' +
                (f'command cp -Rp ./. "$test_folder"\n' if COPY_DIR else "") +
                # note: warning added for sake of shellcheck
                f'command cd "$test_folder" || echo Warning: Unable to "cd $test_folder"\n' +
                "\n")
        ## TODO:
        ## NORMALIZE_WHITESPACE = system.getenv_bool("NORMALIZE_WHITESPACE", False,
        ##                                           "Convert non-newline whitespace to space")
        ## if NORMALIZE_WHITESPACE:
        ##     text = my_re.sub(r"\s(\S)", r" \1", text)
        ##     debug.trace(T9, f"after whitespace normalization: text={text!r}")
        
        # Find all patterns in the text. In special perl-style paragraph mode, the tests
        # must reside within blocks delimited by double newlines (i.e., \n\n).
        all_matches = []
        pattern = "(" + "".join(self._patterns) + ")"
        debug.trace_expr(T7, pattern)
        if not PARA_BLOCKS:
            all_matches = re.findall(pattern, text, flags=self._re_flags)
            if (TRACE_MATCHING and ((len(all_matches) == 0) or debug.debugging(T6))):
                self.trace_pattern_match(text)
        else:
            debug.assertion("\xFF" not in text)
            text = my_re.sub(r"(\n\n+)", "\\1\xFF", text)
            for sub_text in text.split("\xFF"):
                sub_text = self.normalize_block(sub_text)
                debug.trace_expr(T7, sub_text)
                sub_matches = re.findall(pattern, sub_text, flags=self._re_flags)
                if (TRACE_MATCHING and ((len(all_matches) == 0) or debug.debugging(T6))):
                    self.trace_pattern_match(sub_text)
                debug.trace_expr(T6, sub_text, len(sub_matches), delim="\n")
                all_matches += sub_matches

        # Process each match
        for match in all_matches:
            debug.trace(T7, f'batspp (test {self._test_id}) - processing match: {match}')
            debug.assertion(len(match) == 5, 'Incorrect number of groups (see TextTypes), you should review the used regex pattern.')

            test = self._first_process(match)
            debug.assertion(len(test) == 5, f'Incorrect number of fields, every test should be {TestFieldTypes._fields}')
            # Add global setup section directly to BATS output mostly as is (except for prompt removal)
            # pylint: disable=no-member
            if my_re.search(r"^\s*#\s*Global Setup", test.entire, flags=(re.MULTILINE | re.IGNORECASE)):
                debug.trace_expr(T7, test.entire)
                entire_code = my_re.sub(r"^\s*\n", "", test.entire, flags=re.MULTILINE)
                if IGNORE_SETUP_OUTPUT:
                    entire_code = my_re.sub(r"^([^\$\#])[^\n]*\n", "", entire_code, flags=re.MULTILINE)
                debug.assertion(not my_re.search(r"^([^\$\#])", entire_code, flags=re.MULTILINE),
                                "Global setup should not have expected output")
                global_setup = my_re.sub(r'^\s*\$\s*', '', entire_code, flags=re.MULTILINE)
                debug.trace_expr(T6, global_setup)
                bats_tests += global_setup + "\n"
                continue
            
            test = self._common_process(test)
            test = self._last_process(test)
            ## OLD: bats_tests += self._convert_to_bats(test)
            test_spec, title = self._convert_to_bats(test)
            if test_spec:
                bats_tests += test_spec
                test_ids.append(title)

            self._test_id = self.next_id()

        return bats_tests, test_ids

    def merge_continuation(self, actual, expected):
        """Merge EXPECTED content to ACTUAL if likely contintuation lines"""
        debug.trace(T7, f"merge_continuation(_c, _s): len(a)={len(actual)}; len(e)={len(expected)}; self={self}")
        # notes: accounts for function definitions and line continuations.
        # also, experimental code, so enabled with MERGE_CONTINUATION environment setting.
        if (MERGE_CONTINUATION and actual and expected):
            while True:
                new_actual, new_expected = merge_continuation(actual, expected)
                if (new_actual == actual):
                    debug.assertion(new_expected == expected)
                    break
                if ((len(new_actual) + len(new_expected)) != (len(actual) + len(expected))):
                    debug.trace(T6, "Unexpected merge results")
                    break
                actual = new_actual
                expected = new_expected
        return (actual, expected)


class CommandTests(CustomTestsToBats):
    """Extract and process specific command tests"""
    ## TODO: add examples to help clarify the regex

    def __init__(self, verbose_debug=False):
        flags = re.DOTALL | re.MULTILINE | re.IGNORECASE

        # Notes:
        # - Non-capturing groups '(?:regex)' used to ignore certain groupings.
        # - INDENT_PATTERN='^[^\w\$\(\n\{\}]{0}\s*' for batspp file (e.g., from Jupyter).
        # - The optional setup is for commands issued but output not tested.
        # - Example 1:
        #     # Test fu                                              # title
        #     $ cd /tmp                                              # setup
        #     $ pwd                                                  # actual
        #     /tmp                                                   # expected
        # - Example 2:
        #     $ uname                                                # actual
        #     Linux                                                  # expected
        # - The MATCH_SENTINELS option add patterns to capture more context.
        debug.trace_expr(T8, self, INDENT_PATTERN)

        if USE_INDENT_PATTERN:
            patterns = [
                fr'(?:{INDENT_PATTERN} *# Test\s*([^\n]*)\s*\n)+?', # optional test title; non-greedy
                fr'((?:{INDENT_PATTERN}\$\s+[^\n]+\n)*)',           # optional setup
                fr'({INDENT_PATTERN}\$\s+[^\n]+)\n',                # command line [actual]
                r'(.+?)\n',                                         # expected output; non-greedy
                fr'{INDENT_PATTERN}$']                              # end test
        else:
            comment = ("" if Batspp.is_test_file else "#")
            patterns = [
                r'(?#title    )(?:^ *\# *Test +([^\n]*)\n)?',      # optional test title
                # optional setup code w/ explicit start ('# setup') and end ('# actual') indicators
                r'(?#setup    )((?:^ *\# *Setup\n)'        \
                              r'(?:^ *\#? *\$ +[^\n]+\n)*' \
                              r'(?:^ *\# *Actual\n))?',
                ## OLD: fr'(?#actual   )((?:^ *{comment}? *\$ +[^\n]+\n)+)', # command line(s) [actual]
                fr'(?#actual   )((?:^ *{comment}? *[\#\$] *[^\n]*\n)+)', # command line(s) [actual]
                r'(?#expected )(.*)',                              # expected output
                r'(?#end      )^ *\#?\s*\n']                       # end test (blank line)

        super().__init__(patterns, re_flags=flags, verbose_debug=verbose_debug)


    def _first_process(self, match):
        """First process after match, format matched results into [entire, title, setup, actual, expected]"""

        #         title     setup     actual    expected

        assert (len(match) == 5)
        entire, title, setup, actual, expected = match
        actual, expected = self.merge_continuation(actual, expected)

        result = TestFieldTypes(*[entire, title, setup, actual, expected])
                
        debug.trace(T7, f'batspp (test {self._test_id}) - CommandTests._first_process({match}) => {result}')
        return result


    def _last_process(self, test):
        """Process test fields before convert into bats"""

        entire, title, setup, actual, expected = test
        actual, expected = self.merge_continuation(actual, expected)
        
        # Remove $
        # TODO?: flags=re.MULTILINE
        actual = my_re.sub(r'^\$ ', '', actual)
        setup = my_re.sub(r'^\$ ', '', setup, flags=re.MULTILINE)

        result = TestFieldTypes(*[entire, title, setup, actual, expected])
        debug.trace(T7, f'batspp (test {self._test_id}) - CommandTests._last_process({test}) => {result}')
        return result


class FunctionTests(CustomTestsToBats):
    """Extract and process specific function tests"""
    ## TODO: add examples (e.g., to help distinguish regex from one for CommandTests)


    # Class globals
    assert_eq     = r'=>'
    assert_ne     = r'=\/>'


    def __init__(self, verbose_debug=False):

        flags = re.MULTILINE | re.IGNORECASE

        # Notes:
        # - Non-capturing groups '(?:regex)' used for to ignore certain groupings
        # - INDENT_PATTERN='^[^\w\$\(\n\{\}]{0}\s*' for batspp file (e.g., from Jupyter)
        # - Example 1:
        #     # Test fibonacci function                             # title
        #     fibonacci 9 => "0 1 1 2 3 5 8 13 21 34"               # actual assertion-EQ expected
        # - Example 2:
        #     fibonacci 3 =/> "8 2 45 34 3 5"                       # actual assertion-NE expected
        # - Entire match included as well (see get_bats_tests).
        # - MATCH_SENTINELS not needed as => and =/=> constrain the search.
        debug.trace_expr(T8, self, INDENT_PATTERN)

        if USE_INDENT_PATTERN:
            patterns = [
                fr'(?:{INDENT_PATTERN} *# Test\s*([^\n]*)\s*\n)?',   # optional test title
                fr'({INDENT_PATTERN}[^\n]+\w[^\n]+)',                # functions + args line [actual]; '.+?' ???
                fr'\s+({self.assert_eq}|{self.assert_ne})\s+',       # assertion
                r'((?:.|\n)*)',                                      # expected output
                fr'\n{INDENT_PATTERN}$']                             # blank indent (end test)
        else:
            EQ = self.assert_eq
            NE = self.assert_ne
            patterns = [
                r'(?#title    )(?:# Test\s*([^\n]*)\s*\n)?',         # optional test title
                # optional setup code w/ explicit start ('# setup') and end ('# actual') indicators
                r'(?#setup    )((?:^ *\# *Setup\n)'        \
                              r'(?:^ *\#? *\$ +[^\n]+\n)*' \
                              r'(?:^ *\# *Actual\n))?',
                # functions + args line [actual] with assertion
                r'(?#actual   )([^\n]+\w[^\n]+'            \
                              fr'\s+(?:{EQ}|{NE}))\s+',              # assertion
                r'(?#expected )([^\n]+)']                            # expected output

        super().__init__(patterns, re_flags=flags, verbose_debug=verbose_debug)


    def _first_process(self, match):
        """First process after match, format matched results into [entire, title, setup, actual, expected]"""

        entire, title, setup, actual, expected = match

        # Check assertion
        # HACK: assertion put into instance
        # TODO: use OO apprach (e.g., FunctionResult w/ assertion field versus CommandResult with setup)
        if my_re.search(fr'(.*)({self.assert_eq}|{self.assert_ne}).*$', actual):
            actual = my_re.group(1)
            self._assert_equals = (my_re.group(2) == self.assert_eq)

        # Format values
        # Note: uses empty setup
        result = TestFieldTypes(*[entire, title, setup, actual, expected])

        debug.trace(T7, f'batspp (test {self._test_id}) - _first_process({match}) => {result}')
        return result


    def _last_process(self, test):
        """Process test fields before convert into bats"""

        entire, title, setup, actual, expected = test

        # Disable alias adding '//' to functions
        ## TODO: example
        ## BAD: actual = '\\' + actual

        result = TestFieldTypes(*[entire, title, setup, actual, expected])
        debug.trace(T7, f'batspp (test {self._test_id}) - _last_process({test}) => {result}')
        return result

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    app = Batspp(description          = __doc__.format(prog=gh.basename(__file__)),
                 ## TODO: use_temp_base_dir=True,
                 positional_arguments = [(TESTFILE, 'test file path')],
                 boolean_options      = [(VERBOSE,  'show verbose debug'),
                                         (FORCE,    'Run even under admin-like account'),
                                         (JUPYTER,  'Convert jupyter file to batspp')],
                 text_options         = [(OUTPUT,   'target output .bats filepath'),
                                         (SOURCE,   'file to be sourced')],
                 manual_input         = True)
    app.run()
