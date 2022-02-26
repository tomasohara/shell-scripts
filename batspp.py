#! /usr/bin/env python
#
# PYBATS
#
# This process and run custom tests using bats-core.
#
# NOTE: It is only necessary to have installed bats-core
#       no need for bats-assertions library.
#
## TODO: solve test alias.
##       pretty result.
##       debug tests.
##       negative assertion (=/>).
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

        debug.trace(7, f'pybats - filename to run tests: {self.filename}')


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
        debug.trace(7, f'pybats - running test {self.temp_file}')
        print(gh.run(f'bats {self.temp_file}'))


    def __process_setup(self):
        """Process tests setup"""
        debug.trace(7, f'pybats - processing setup')


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


    def __process_teardown(self):
        """Process teardown"""
        debug.trace(7, f'pybats - processing teardown')
        # WORK-IN-PROGRESS


    def __process_tests(self):
        """Process tests"""
        debug.trace(7, f'pybats - processing tests')


        # Setup patterns
        # NOTE: repeated patterns code but improves readability.
        indent_pattern = r'^[^\w\$\(\n\{\}]'

        command_test_pattern = (fr'({indent_pattern}*)' # indent
                                r'\$\s+(.+?)\n'         # command
                                r'(.+?)\n'              # expected output
                                fr'{indent_pattern}*$') # blank indent (end test)
        debug.trace(7, f'batspp - pattern for command tests: {command_test_pattern}')

        function_test_pattern = (fr'({indent_pattern}*)'   # indent
                                 r'(.+?)'                  # functions + args
                                 r'\s+=>\s+'               # assert equals
                                 r'((.|\n)+?)'             # expected output
                                 fr'\n{indent_pattern}*$') # blank indent (end test)
        debug.trace(7, f'batspp - pattern for function tests: {function_test_pattern}')


        # Extract tests
        command_tests  = CommandTestsExtractor(command_test_pattern, re.DOTALL | re.MULTILINE)
        function_tests = FunctionTestsExtractor(function_test_pattern, re.MULTILINE)

        tests  = []
        tests += command_tests.get_tests(self.file_content)
        tests += function_tests.get_tests(self.file_content)


        # Append tests
        for actual, expected in tests:
            self.bats_content += (f'@test {repr(actual)[:-1]} should return {repr(expected)[1:]} {{\n'
                                  f'\tactual=$({actual})\n'
                                  f'\texpected=${repr(expected)}\n'
                                  f'\t[ "$actual" == "$expected" ]\n'
                                  '}\n\n')


class TestsExtractor:
    """Class TestsExtractor for extract and process tests"""


    def __init__(self, pattern, re_flags):
        self._pattern    = pattern
        self._re_flags   = re_flags
        self._tests_list = []


    def _extract_from_text(self, text):
        """Extract tests from text"""

        self._tests_list = re.findall(self._pattern, text, flags=self._re_flags)

        # Ensure that there is only 3 groups per test
        for i, test in enumerate(self._tests_list):
            #                      indent   actual  expected
            self._tests_list[i] = (test[0], test[1], test[2])

        debug.trace(7, f'pybats - tests founded: {self._tests_list}')


    def _remove_indent(self):
        """Remove indent of assertion"""
        for i, test in enumerate(self._tests_list):
            indent, command, expected = test
            self._tests_list[i] = (command, re.sub(indent, '', expected))

        debug.trace(7, f'pybats - indent removed from tests: {self._tests_list}')


    def _sanitize(self):
        """Sanitize tests"""
        for i, test in enumerate(self._tests_list):
            command, expected = test

            # Strip whitespaces
            command  = command.strip()
            expected = expected.strip()

            # Remove initial and trailing quotes
            command = re.sub(f'^(\"|\')(.*)(\"|\')$', r'\2', command)
            expected = re.sub(f'^(\"|\')(.*)(\"|\')$', r'\2', expected)

            self._tests_list[i] = (command, expected)

        debug.trace(7, f'pybats - sanitized tests: {self._tests_list}')


    def get_tests(self, text):
        """Extract and process tests from text"""
        self._extract_from_text(text)
        self._remove_indent()
        self._sanitize()

        debug.trace(7, f'pybats - final test list: {self._tests_list}')
        return self._tests_list


# NOTE: this is not necessary but it improves readability.
class CommandTestsExtractor(TestsExtractor):
    """Class CommandTestsExtractor to extract and process specific command tests"""


class FunctionTestsExtractor(TestsExtractor):
    """Class FunctionTestsExtractor to extract and process specific function tests"""


    def _disable_alias(self):
        """Disable alias adding // in functions tests"""
        for i, test in enumerate(self._tests_list):
            command, expected = test
            self._tests_list[i] = ('\\' + command, expected)
        debug.trace(7, f'pybats - disabled alias to tests: {self._tests_list}')


    def get_tests(self, text):
        """Extract and process tests from text"""
        self._extract_from_text(text)
        self._remove_indent()
        self._disable_alias()
        self._sanitize()

        debug.trace(7, f'pybats - final test list: {self._tests_list}')
        return self._tests_list


if __name__ == '__main__':
    app = Batspp(description          = __doc__,
                 positional_arguments = [(FILENAME, 'test file path')],
                 manual_input         = True)
    app.run()
