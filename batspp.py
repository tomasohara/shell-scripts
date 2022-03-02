#! /usr/bin/env python
#
# BATSPP
#
# This process and run custom tests using bats-core.
#
# NOTE: It is only necessary to have installed bats-core
#       no need for bats-assertions library.
#
## TODO: pretty result.
##       setup for functions tests.
##       debug tests.
##       --save PATH for bats file?.


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


# Local packages
from mezcla.main import Main
from mezcla      import system
from mezcla      import debug
from mezcla      import glue_helpers as gh


# Command-line labels constants
FILENAME = 'filepath'


# Pattern constants
INDENT_PATTERN = r'^[^\w\$\(\n\{\}]*'


class Batspp(Main):
    """This process and run custom tests using bats-core"""


    # Global States
    filename     = ''
    file_content = ''
    bats_content = '#!/usr/bin/env bats\n\n'


    def setup(self):
        """Process arguments"""

        # Check the command-line options
        self.filename     = self.get_parsed_argument(FILENAME, "")
        self.file_content = system.read_file(self.filename)

        debug.trace(7, f'batspp - filename to run tests: {self.filename}')


    def run_main_step(self):
        """Process main script"""


        # Check if finish with newline
        if not self.file_content.endswith('\n\n'):
            self.file_content += '\n'


        self.__process_setup()
        self.__process_teardown()
        self.__process_tests()


        # Save test file and run tests
        gh.write_file(self.temp_file, self.bats_content)
        debug.trace(7, f'batspp - running test {self.temp_file}')
        print(gh.run(f'bats {self.temp_file}'))


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
        #  	  └ tests/test_script.bpp
        ## TODO: add optional target dir.
        self.bats_content += ('\t# Make executables ./tests/../ visible to PATH\n'
                              f'\tDIR="{gh.dir_path(gh.real_path(self.filename))}/../:$PATH"\n')


        # Load file
        self.bats_content += ('\n\t# Load file\n'
                              '\tshopt -s expand_aliases\n'
                              f'\tsource {gh.real_path(self.filename)}\n'
                              '}\n\n')


    # pylint: disable=no-self-use
    def __process_teardown(self):
        """Process teardown"""
        debug.trace(7, f'pybats - processing teardown')
        # WORK-IN-PROGRESS


    def __process_tests(self):
        """Process tests"""
        debug.trace(7, f'batspp - processing tests')

        command_tests  = CommandTests()
        function_tests = FunctionTests()

        self.bats_content += command_tests.get_bats_tests(self.file_content)
        self.bats_content += function_tests.get_bats_tests(self.file_content)


class CustomTestsToBats:
    """Base class to extract and process tests"""

    # Debug global class variables
    _debug_test_number = 0


    def __init__(self, pattern, re_flags=0):
        self._re_flags      = re_flags
        self._pattern       = pattern
        self._assert_equals = True


    def _first_process(self, match):
        """First process after match, format matched results into [indent, setup, actual, expected]"""

        # NOTE: this must be overriden.
        # NOTE: the returned values must be like:
        result = ['indent', 'setup', 'actual', 'expected']

        debug.trace(7, f'batspp (test {self._debug_test_number}) - _first_process({match}) => {result}')
        return result


    def _sanitize(self, test):
        """Remove indent and sanitize test fields"""

        result = [test[0]]

        for field in test[1:]:

            # Remove indent
            field = re.sub(test[0], '', field)

            # Strip whitespaces
            field = field.strip()

            # Remove initial and trailing quotes
            field = re.sub(f'^(\"|\')(.*)(\"|\')$', r'\2', field)

            result.append(field)

        debug.trace(7, f'batspp (test {self._debug_test_number}) - _sanitize({test}) => {result}')
        return result


    def _last_process(self, test):
        """Process test fields before convert into bats"""

        # NOTE: if this is overrided, the result must be:
        # result = ['indent', 'setup', 'actual', 'expected']

        result = test

        debug.trace(7, f'batspp (test {self._debug_test_number}) - _last_process({test}) => {result}')
        return result


    def _convert_to_bats(self, test):
        """Convert tests to bats format"""
        _, setup, actual, expected = test

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

        result += f'\tactual=$({actual})\n'
        result += f'\t{expected_var_name}=${repr(expected)}\n'

        # Add assertion
        result += f'\t[ "$actual" {"==" if self._assert_equals else "!="} "${expected_var_name}" ]\n'

        # End test
        result += '}\n\n'

        debug.trace(7, f'batspp (test {self._debug_test_number}) - _convert_to_bats({test}) =>\n{result}')
        return result


    def get_bats_tests(self, text):
        """Returns BATS tests"""

        debug.trace(7, f'batspp - pattern used ({self._re_flags}): {self._pattern}')

        bats_tests = ''

        for match in re.findall(self._pattern, text, flags=self._re_flags):

            test = self._first_process(match)
            if len(test) == 4:
                test = self._sanitize(test)
                test = self._last_process(test)
                bats_tests += self._convert_to_bats(test)
            else:
                debug.trace(7, f'batspp (test {self._debug_test_number}) - wrong number of fields ({test}).')

            self._debug_test_number += 1

        return bats_tests


class CommandTests(CustomTestsToBats):
    """Extract and process specific command tests"""


    def __init__(self):
        flags = re.DOTALL | re.MULTILINE

        pattern = (fr'(({INDENT_PATTERN}\$\s+[^\n]+\n)*)' # setup
                   fr'({INDENT_PATTERN})\$\s+([^\n]+)\n'  # command test
                   fr'(.+?)\n'                            # expected output
                   fr'{INDENT_PATTERN}$')                 # end test

        super().__init__(pattern, re_flags=flags)


    def _first_process(self, match):
        """First process after match, format matched results into [indent, setup, actual, expected]"""

        #         indent     setup     actual   expected
        result = [match[2], match[0], match[3], match[4]]

        debug.trace(7, f'batspp (test {self._debug_test_number}) - _first_process({match}) => {result}')
        return result


class FunctionTests(CustomTestsToBats):
    """Extract and process specific function tests"""


    # Class globals
    assert_eq     = r'=>'
    assert_ne     = r'=\/>'


    def __init__(self):

        flags = re.MULTILINE

        pattern = (fr'({INDENT_PATTERN})'                        # indent
                   r'(.+?)'                                      # functions + args
                   fr'\s+({self.assert_eq}|{self.assert_ne})\s+' # assertion
                   r'((.|\n)+?)'                                 # expected output
                   fr'\n{INDENT_PATTERN}$')                      # blank indent (end test)

        super().__init__(pattern, re_flags=flags)


    def _first_process(self, match):
        """First process after match, format matched results into [indent, setup, actual, expected]"""

        indent, actual, assertion, expected, _ = match

        # Check assertion
        if assertion == self.assert_eq:
            self._assert_equals = True
        elif assertion == self.assert_ne:
            self._assert_equals = False
        else:
            self._assert_equals = None

        # Format values
        result = [indent, '', actual, expected]

        debug.trace(7, f'batspp (test {self._debug_test_number}) - _first_process({match}) => {result}')
        return result


    def _last_process(self, test):
        """Process test fields before convert into bats"""

        indent, setup, actual, expected = test

        # Disable alias adding '//' to functions
        actual = '\\' + actual

        result = [indent, setup, actual, expected]
        debug.trace(7, f'batspp (test {self._debug_test_number}) - _last_process({test}) => {result}')
        return result


if __name__ == '__main__':
    app = Batspp(description          = __doc__,
                 positional_arguments = [(FILENAME, 'test file path')],
                 manual_input         = True)
    app.run()
