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
## - Only source the script if it is a shell script.
## - add an option to source another script.
## - ignore tests in comments if the file has extension .batspp (i.e., test file not bash script).
## - Add some directives in the test or script comments:
##        Block of commands used just to setup test and thus without output or if the output should be ignored (e.g., '# Setup').
##        Tests that should be evaluated in the same environment as the preceding code (e.g., '# Continuation'). For example, you could have multiple assertions in the same @test function.
##        Name of the test (e.g., '# Test <name>')
## - Automatically create test directory using test name (e.g., /tmp/test-empty-file).
## - Add option for outputting debugging information (e.g, echo out actual and expected). And if under verbose debugging output a hexdump of each.
## - find regex match excluding indent directly.
## - pretty result.
## - setup for functions tests.
## - multiline commands?.
## - solve comma sanitization, test poc:
##        $ BATCH_MODE=1 bash -i -c 'source ../tomohara-aliases.bash; mkdir -p $TMP/test-$$; cd $TMP/test-$$; touch  F1.txt F2.list F3.txt F4.list F5.txt; ls | old-count-exts'
##        .txt\t3
##        .list\t2
## - add a tag to avoid running a certain test (example "# OLD").


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
import random


# Local packages
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla      import system
from mezcla      import debug
from mezcla      import glue_helpers as gh


# Command-line labels constants
FILENAME = 'filepath' # target test path
OUTPUT   = 'output'   # output BATS test
DEBUG    = 'debug'    # show actual and expected values


# Pattern constants
INDENT_PATTERN = r'^[^\w\$\(\n\{\}]*'


class Batspp(Main):
    """This process and run custom tests using bats-core"""


    # Class-level member variables for arguments (avoids need for class constructor)
    filename     = ''
    output       = ''
    debug_mode   = False


    # Global States
    file_content = ''
    bats_content = '#!/usr/bin/env bats\n\n'


    def setup(self):
        """Process arguments"""

        # Check the command-line options
        self.filename     = self.get_parsed_argument(FILENAME, "")
        self.output       = self.get_parsed_argument(OUTPUT, "")
        self.debug_mode   = self.has_parsed_option(DEBUG)

        debug.trace(7, f'batspp - filename: {self.filename}, output: {self.output}, debug_mode: {self.debug_mode}')


    def run_main_step(self):
        """Process main script"""

        # Read file content
        self.file_content = system.read_file(self.filename)


        # Check if finish with newline
        if not self.file_content.endswith('\n\n'):
            self.file_content += '\n'


        self.__process_setup()
        self.__process_teardown()
        self.__process_tests()


        # Save
        batsfile = self.output if self.output else self.temp_file
        gh.write_file(batsfile, self.bats_content)


        # Add execution permission to directly run the result test file
        if self.output:
            gh.run(f'chmod +x {batsfile}')


        # Run
        debug.trace(7, f'batspp - running test {self.temp_file}')
        print(gh.run(f'bats {batsfile}'))


    def __process_setup(self):
        """Process tests setup"""
        debug.trace(7, f'batspp - processing setup')


        self.bats_content +=  'setup() {\n'


        # Make executables ./tests/../ visible to PATH
        #
        # This is usefull then the file is specially for testing.
        #
        # The structure should be:
        #  project
        #     ├ script.bash
        #  	  └ tests/test_script.batspp
        ## TODO: add optional target dir.
        self.bats_content += ('\t# Make executables ./tests/../ visible to PATH\n'
                              f'\tDIR="{gh.dir_path(gh.real_path(self.filename))}/../:$PATH"\n'
                              '}\n\n')

        # Load file
        # NOTE: this is outside the function setup
        #       to avoid problems with function commands.
        self.bats_content += ('\n# Load file\n'
                              'shopt -s expand_aliases\n'
                              f'source {gh.real_path(self.filename)} || true\n\n\n')


    # pylint: disable=no-self-use
    def __process_teardown(self):
        """Process teardown"""
        debug.trace(7, f'batspp - processing teardown')
        # WORK-IN-PROGRESS


    def __process_tests(self):
        """Process tests"""
        debug.trace(7, f'batspp - processing tests')

        command_tests  = CommandTests(debug_mode=self.debug_mode)
        function_tests = FunctionTests(debug_mode=self.debug_mode)

        self.bats_content += command_tests.get_bats_tests(self.file_content)
        self.bats_content += function_tests.get_bats_tests(self.file_content)


class CustomTestsToBats:
    """Base class to extract and process tests"""


    def __init__(self, pattern, re_flags=0, debug_mode=False):
        self._debug_mode    = debug_mode
        self._re_flags      = re_flags
        self._pattern       = pattern
        self._assert_equals = True
        self._test_id       = random.randint(1, 999999) # differentiate tests


    def _first_process(self, match):
        """First process after match, format matched results into [setup, actual, expected]"""

        # NOTE: this must be overriden.
        # NOTE: the returned values must be like:
        result = ['title', 'setup', 'actual', 'expected']

        debug.trace(7, f'batspp (test {self._test_id}) - _first_process({match}) => {result}')
        return result


    def _common_process(self, test):
        """Common process for each field in test"""

        result = []

        # Get indent used
        indent_used = ''
        if my_re.match(INDENT_PATTERN, test[2]):
            indent_used = my_re.group(0)
            debug.trace(7, f'batspp (test {self._test_id}) - indent founded: "{indent_used}"')

        for field in test:

            # Remove indent
            field = re.sub(fr'^{indent_used}', '', field, flags=re.MULTILINE)

            # Strip whitespaces
            field = field.strip()

            # Remove initial and trailing quotes
            field = re.sub(f'^(\"|\')(.*)(\"|\')$', r'\2', field)

            result.append(field)

        debug.trace(7, f'batspp (test {self._test_id}) - _common_process({test}) => {result}')
        return result


    def _last_process(self, test):
        """Process test fields before convert into bats"""

        # NOTE: if this is overrided, the result must be:
        # result = ['title', 'setup', 'actual', 'expected']

        result = test

        debug.trace(7, f'batspp (test {self._test_id}) - _last_process({test}) => {result}')
        return result


    def _convert_to_bats(self, test):
        """Convert tests to bats format"""
        title, setup, actual, expected = test

        result = ''

        # Add test header
        result += f'@test {repr(actual)[:-1]} should {"" if self._assert_equals else "NOT "}return {repr(expected)[1:]} {{\n'

        # Add test setup
        for setup_command in setup.splitlines():
            if setup_command:
                setup_command = re.sub(r'(^\$\s+|\n+$)', '', setup_command)
                result       += f'\t{setup_command}\n'

        # Add actual and expected (or not)
        expected_var_name = f'{"" if self._assert_equals else "not_"}expected'

        title = title if title else f'test-{self._test_id}'

        actual_function_name = f'{title}-actual'
        expected_function_name = f'{title}-{expected_var_name}'

        result += f'\tactual=$({actual_function_name})\n'
        result += f'\t{expected_var_name}=$({expected_function_name})\n'

        # Add debug
        if self._debug_mode:
            result += ('\techo ========== actual ==========\n'
                       '\techo "$actual"\n'
                       '\techo ========= expected =========\n'
                       f'\techo "${expected_var_name}"\n'
                       '\techo ============================\n')

        # Add assertion
        result += f'\t[ "$actual" {"==" if self._assert_equals else "!="} "${expected_var_name}" ]\n'

        # End test
        result += '}\n\n'

        # Add actual and expected (or not) functions
        result += self._get_bash_function(actual_function_name, actual)
        result += self._get_bash_function(expected_function_name, f'echo -e {repr(expected)}')

        debug.trace(7, f'batspp (test {self._test_id}) - _convert_to_bats({test}) =>\n{result}')
        return result


    def _get_bash_function(self, name, content):
        """Return bash function"""
        result = (f'function {name} () {{\n'
                  f'\t{content}\n'
                  '}\n\n')
        debug.trace(7, f'batspp (test {self._test_id}) - get_bash_function(name={name}, content={content}) => {result}')
        return result


    def get_bats_tests(self, text):
        """Returns BATS tests"""

        debug.trace(7, f'batspp - pattern used ({self._re_flags}): {self._pattern}')

        bats_tests = ''

        for match in re.findall(self._pattern, text, flags=self._re_flags):
            debug.trace(7, f'batspp (test {self._test_id}) - processing match: {match}')
            debug.assertion(len(match) >= 4, f'Insufficient groups, you should review the used regex pattern.')

            test = self._first_process(match)
            test = self._common_process(test)
            test = self._last_process(test)
            bats_tests += self._convert_to_bats(test)

            self._test_id = random.randint(1, 999999)

        return bats_tests


class CommandTests(CustomTestsToBats):
    """Extract and process specific command tests"""


    def __init__(self, debug_mode=False):
        flags = re.DOTALL | re.MULTILINE

        pattern = (fr'(({INDENT_PATTERN}\$\s+[^\n]+\n)*)' # setup
                   fr'({INDENT_PATTERN}\$\s+[^\n]+)\n'    # command test line
                   fr'(.+?)\n'                            # expected output
                   fr'{INDENT_PATTERN}$')                 # end test

        super().__init__(pattern, re_flags=flags, debug_mode=debug_mode)


    def _first_process(self, match):
        """First process after match, format matched results into [setup, actual, expected]"""

        # TODO: add title.
        #       title  setup    actual    expected
        result = ['', match[0], match[2], match[3]]

        debug.trace(7, f'batspp (test {self._test_id}) - _first_process({match}) => {result}')
        return result


    def _last_process(self, test):
        """Process test fields before convert into bats"""

        title, setup, actual, expected = test

        # Remove $
        actual = re.sub(r'^\$\s*', '', actual)

        result = title, setup, actual, expected
        debug.trace(7, f'batspp (test {self._test_id}) - _last_process({test}) => {result}')
        return result


class FunctionTests(CustomTestsToBats):
    """Extract and process specific function tests"""


    # Class globals
    assert_eq     = r'=>'
    assert_ne     = r'=\/>'


    def __init__(self, debug_mode=False):

        flags = re.MULTILINE

        pattern = (fr'({INDENT_PATTERN}.+?)'                     # functions + args line
                   fr'\s+({self.assert_eq}|{self.assert_ne})\s+' # assertion
                   r'((.|\n)+?)'                                 # expected output
                   fr'\n{INDENT_PATTERN}$')                      # blank indent (end test)

        super().__init__(pattern, re_flags=flags, debug_mode=debug_mode)


    def _first_process(self, match):
        """First process after match, format matched results into [setup, actual, expected]"""

        # TODO: add title.
        actual, assertion, expected, _ = match

        # Check assertion
        if assertion == self.assert_eq:
            self._assert_equals = True
        elif assertion == self.assert_ne:
            self._assert_equals = False
        else:
            self._assert_equals = None

        # Format values
        result = ['', '', actual, expected]

        debug.trace(7, f'batspp (test {self._test_id}) - _first_process({match}) => {result}')
        return result


    def _last_process(self, test):
        """Process test fields before convert into bats"""

        title, setup, actual, expected = test

        # Disable alias adding '//' to functions
        actual = '\\' + actual

        result = [title, setup, actual, expected]
        debug.trace(7, f'batspp (test {self._test_id}) - _last_process({test}) => {result}')
        return result


if __name__ == '__main__':
    app = Batspp(description          = __doc__,
                 positional_arguments = [(FILENAME, 'test file path')],
                 boolean_options      = [(DEBUG,    'show actual and expected values')],
                 text_options         = [(OUTPUT,   'target output .bats filepath')],
                 manual_input         = True)
    app.run()
