#! /usr/bin/env python
#
# BATSPP
#
# This process and run custom tests using bats-core.
#
# NOTE: It is only necessary to have installed bats-core
#       no need for bats-assertions library.
#
## TODO:
## - print test line number to help debugging.
## - extend usage guide or docstring.
## - Block of commands used just to setup test and thus without output or if the output should be ignored (e.g., '# Setup').
## - pretty result.
## - setup for functions tests.
## - multiline commands?.
##   treat whitespace as single space  (e.g., '# normalize-whitespace')
##   treat output as is (e.g., '# verbatim')
## - get batspp.py fixed so that first empty line after $-based run line terminates output


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
"""


# Standard packages
import re
from socket import VMADDR_CID_HOST


# Local packages
from mezcla.main import Main
from mezcla      import system
from mezcla      import debug
from mezcla      import glue_helpers as gh


# Command-line labels constants
TEST_FILE = 'test_file' # target test path
OUTPUT   = 'output'   # output BATS test
SOURCE   = 'source'   # source another file


# Common constants
BATSPP_EXTENSION = '.batspp'
TITLE     = 'title'
SETUP     = 'setup'
ASSERT_EQ = 'assert_eq'
ASSERT_NE = 'assert_ne'
ACTUAL    = 'actual'
EXPECTED  = 'expected'
TAGS      = [('<blank>', ' '),
             ('<blank-line>', '\n'),
             ('<tab>', '\t')]


class Batspp(Main):
    """This process and run custom tests using bats-core"""


    # Class-level member variables for arguments (avoids need for class constructor)
    test_file = ''
    output   = ''
    source   = ''


    # Global States
    is_test_file = False
    file_content = ''
    bats_content = '#!/usr/bin/env bats\n\n\n'
    test_count   = 0


    def setup(self):
        """Process arguments"""
        debug.trace(7, f'batspp.setup({self})')

        # Check the command-line options
        self.test_file = self.get_parsed_argument(TEST_FILE, self.test_file)
        self.output   = self.get_parsed_argument(OUTPUT, self.output)
        self.source   = self.get_parsed_argument(SOURCE, self.source)

        debug.trace(7, (f'batspp - test_file: {self.test_file}, '
                        f'output: {self.output}, '
                        f'source: {self.source}'))


    def run_main_step(self):
        """Process main script"""
        debug.trace(7, f'batspp.run_main_step({self})')

        # Check if is test of shell script file
        self.is_test_file = self.test_file.endswith(BATSPP_EXTENSION)
        debug.trace(7, f'batspp - {self.test_file} is a test file (not shell script): {self.is_test_file}')


        # Read file content
        self.file_content = system.read_file(self.test_file)


        # Check if finish with newline
        if not self.file_content.endswith('\n\n'):
            self.file_content += '\n'


        self.__process_global_setup()
        self.__process_teardown()
        self.__process_tests()


        # Check if tests was founded
        if not re.search(r'\@[Tt]est', self.bats_content):
            print(f'Error: no tests founded on {self.test_file}.')
            return


        # Set Bats filename
        if self.output:
            batsfile = self.output
            if batsfile.endswith('/'):
                name = re.search(r"\/(\w+)\.", self.test_file).group(0)
                batsfile += f'{name}.bats'
        else:
            batsfile = self.temp_file


        # Save Bats file
        gh.write_file(batsfile, self.bats_content)


        # Add execution permission to directly run the result test file
        if self.output:
            gh.run(f'chmod +x {batsfile}')


        # Run
        debug.trace(7, f'batspp - running test {batsfile}')
        print(gh.run(f'bats {batsfile}'))


    def __process_global_setup(self):
        """Process tests global setup"""
        debug.trace(7, f'batspp.__process_global_setup({self})')


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
        self.bats_content += ('# Make executables ./tests/../ visible to PATH\n'
                              f'PATH="{gh.dir_path(gh.real_path(self.test_file))}/../:$PATH"\n\n')


        # Source Files
        self.bats_content += ('# Source files\n'
                              'shopt -s expand_aliases\n')

        if not self.is_test_file:
            self.bats_content += f'source {gh.real_path(self.test_file)} || true\n'

        if self.source:
            self.bats_content += f'source {gh.real_path(self.source)} || true\n'

        self.bats_content += '\n\n'


        # Debug function
        ## TODO: refactor: add bash function to print actual and expected debug.
        ## f'\techo "========== {actual} =========="\n'
        ## f'\techo "${actual}" | hexview.perl\n'
        ## f'\techo "========= {expected} ========="\n'
        ## f'\techo "${expected}" | hexview.perl\n'
        ## '\techo "============================"\n'
        ## f'\t[ "${actual}" {assertion} "${expected}" ]\n'


    ## pylint: disable=no-self-use
    def __process_teardown(self):
        """Process teardown"""
        ## debug.trace(7, f'batspp - processing teardown')
        ## WORK-IN-PROGRESS


    def __process_tests(self):
        """Process tests"""
        debug.trace(7, f'batspp.__process_tests({self})')


        # Regex common patterns
        RE_TITLE = r'[Tt]est'
        RE_CONTINUATION = r'(?:[Cc]ontinue|[Cc]ontinuation|[Ss]etup)'
        re_indent = r'^[^\w\$\(\n\{\}]'

        # Tests with simple indentation (i.e. #) are ignored on batspp files.
        # Tests with double indentation (i.e. ##) are ignored on shell scripts.
        re_indent += r'{0}' if self.is_test_file else r'?'


        # Extract raw tests
        # Simplified regex example: https://regex101.com/r/jceKgu/1
        re_pattern       = fr'(?P<test>(?:(?:{re_indent} +{RE_TITLE} +(?P<title1>[^\n]+) *$\n)?(?:{re_indent} +(?P<continuation>{RE_CONTINUATION}) *$\n)?(?:(?:{re_indent} *\$ *[^\n]+$\n)+(?:{re_indent} *[^\n]+$\n)*?)+(?:{re_indent} *$\n))|(?:{re_indent} +{RE_TITLE} +(?P<title2>[^\n]+) *$\n))'
        re_flags         = re.DOTALL | re.MULTILINE
        tests            = []
        last_title_index = 0
        ## TODO: refactor: replace by finditer.
        debug.trace(7, f'batspp - extract raw tests using flags => {re_flags} and pattern => {re_pattern}')
        for match in re.findall(re_pattern, self.file_content, flags=re_flags):
            test, _, continuation, _ = match
            title = match[1] or match[3]
            if title:
                tests.append(test)
                last_title_index = len(tests) - 1
            elif continuation:
                tests[last_title_index] += f'\n{test}'
            else:
                tests.append(test)


        # Process tests
        # Simplified regex example: https://regex101.com/r/tliu64/1
        re_pattern = fr'{re_indent} *(?:(?:\$ *(?P<setup>[^\n]+) *$\n(?={re_indent} *(?:\$ *[^\n]+)?$\n))|(?:(?P<assert_eq>\$) *(?P<actual>[^\n]+) *$\n(?={re_indent} *\w+))|(?:(?:{RE_TITLE} +(?P<title>.+?)$\n)|[Cc]ontinue|[Cc]ontinuation|[Ss]etup)|(?:(?P<expected>[^\n]+)?$\n))'
        for test in tests:
            test = extract_test_data(test, re_pattern, re_flags)
            test = format_bats_test(test, default_title=f"test{self.test_count}")
            test = replace_tags(TAGS, test)
            self.bats_content += test
            self.test_count   += 1


def extract_test_data(text, pattern, flags):
    """
    Extract test in TEXT and return the test data.
    the provided PATTERN must contain at least
    one of the following groups:
    - 'title' (optional)
    - 'setup' (optional)
    - 'assert_eq' and/or 'assert_ne'
    - 'actual' and 'expected'
    e.g. of returned DATA:
    [('title', 'print file content'),
     ('setup', 'touch /tmp/test_file.txt'),
     ('setup', 'echo "this is an example" > /tmp/test_file.txt'),
     ('assert_eq', 'echo /tmp/test_file.txt', 'this is an example')]
    """
    debug.trace(7, f'batspp.extract_test_data(pattern={pattern}, flags={flags}, text={text})')

    data = []

    # Assertion vars
    last_assertion = ''
    last_actual    = ''
    last_expected  = ''

    # Remove indented lines without text
    ## TODO: check if this is necessary.
    ## text = re.sub(fr'{re_indent}$\n', r'\n', text, flags=flags)

    # Extract test groups
    for match in re.finditer(pattern, text, flags=flags):
        match = match.groupdict()

        if not any(match.values()):
            continue

        debug.trace(7, f'batspp.extract_test_data() - match: {match}')

        # Process title
        # resulted tests always will contain a title,
        # a default title is asigned if there is no title
        if not data:
            data.append((TITLE, match.get(TITLE)))

        # Process local test setup
        if match.get(SETUP):
            data.append((SETUP, match.get(SETUP)))

        # Process actual
        if match.get(ACTUAL):
            if last_actual and last_assertion:
                data.append((last_assertion, last_actual, last_expected))
                last_assertion = last_actual = last_expected = ''
            last_actual = match.get(ACTUAL)

        # Process assertion type
        if match.get(ASSERT_EQ):
            if last_actual and last_assertion:
                data.append((last_assertion, last_actual, last_expected))
                last_assertion = last_actual = last_expected = ''
            last_assertion = ASSERT_EQ
        elif match.get(ASSERT_NE):
            if last_actual and last_assertion:
                data.append((last_assertion, last_actual, last_expected))
                last_assertion = last_actual = last_expected = ''
            last_assertion = ASSERT_NE

        # Process expected
        if match.get(EXPECTED) and last_actual:
            last_expected += match.get(EXPECTED)

    # Add remain assertion
    if last_assertion and last_actual and last_expected:
        data.append((last_assertion, last_actual, last_expected))

    debug.trace(7, f'batspp.extract_test_data( ... ) => {data}')
    return data


def format_bats_test(data, default_title=""):
    """
    Convert DATA and return Bats test string,
    DATA should be: [ ('directive', 'content', 'content') ... ]
    e.g. of DATA:
    [('title', 'print file content'),
     ('setup', 'touch /tmp/test_file.txt'),
     ('setup', 'echo "this is an example" > /tmp/test_file.txt'),
     ('assert_eq', 'echo /tmp/test_file.txt', 'this is an example')]
    directives can be:
    - 'title': must be one per test.
    - 'setup': this is a single line command, could be multiples per test.
    - 'assert_eq': must contain the 'actual' and 'expected', could be multiples per test.
    - 'assert_ne': same as 'assert_eq' but negative, could be multiples per test.
    """

    result         = ''
    title          = ''
    unspaced_title = ''
    functions      = ''

    for index, element in enumerate(data):

        # Process title
        if TITLE in element[0]:
            title          = element[1] if element[1] else default_title
            unspaced_title = re.sub(r'\s+', '-', title)
            result        += (f'@test "{title}" {{\n'
                              f'\ttest_folder=$(echo /tmp/{unspaced_title}-$$)\n'
                              f'\tmkdir $test_folder && cd $test_folder\n\n')

        # Process local test setup
        if SETUP in element[0]:
            result += f'\t{element[1]}\n'

        # Process assertions
        if 'assert' in element[0]:

            assertion = ''
            actual    = ACTUAL
            expected  = ''

            # Assertion type
            if element[0] == ASSERT_EQ:
                assertion = '=='
                expected  = EXPECTED
            elif element[0] == ASSERT_NE:
                assertion = '!='
                expected  = f'not-{EXPECTED}'
            else:
                continue

            # Actual and expected functions
            actual_function   = f'{unspaced_title}-assert{index}-{actual}'
            expected_function = f'{unspaced_title}-assert{index}-{expected}'
            functions        += get_bash_function(actual_function, element[1])
            functions        += get_bash_function(expected_function, f'echo -e {repr(element[2])}')

            # Append actual, expected and debug
            ## TODO: refactor: convert to bash function in setup.
            result += (f'\t{actual}=$({actual_function})\n'
                       f'\t{expected}=$({expected_function})\n'
                       f'\techo "========== {actual} =========="\n'
                       f'\techo "${actual}" | hexview.perl\n'
                       f'\techo "========= {expected} ========="\n'
                       f'\techo "${expected}" | hexview.perl\n'
                       '\techo "============================"\n'
                       f'\t[ "${actual}" {assertion} "${expected}" ]\n\n')

    result += f'}}\n\n{functions}\n'

    debug.trace(7, f'batspp.format_bats_test(data={data}) => {result}')
    return result


def get_bash_function(name, content):
    """Return bash function string"""

    result = f'function {name} () {{\n'
    for line in content.splitlines():
        result += f'\t{line}\n'
    result += '}\n'

    debug.trace(7, f'batspp.get_bash_function(name={name}, content={content}) => {result}')
    return result


def replace_tags(tags, text):
    """
    Convert TAGS in TEXT into its respective value.
    e.g.:
    <blank> => ' '
    <tab>   => '\t'
    """

    result = text
    for tag, replacement in tags:
        result = re.sub(tag, replacement, result)

    debug.trace(7, f'batspp.replace_tags(tags={tags}, text={text}) => {result}')
    return result


if __name__ == '__main__':
    app = Batspp(description          = __doc__,
                 positional_arguments = [(TEST_FILE, 'test file path')],
                 text_options         = [(OUTPUT,   'target output .bats filepath'),
                                         (SOURCE,   'file to be sourced')],
                 manual_input         = True)
    app.run()
