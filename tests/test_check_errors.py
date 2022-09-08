#! /usr/bin/env python
#
# Tests for check_errors module


"""Tests for check_errors module"""


# Standard packages
import unittest

# Installed packages
## NOTE: this is empty for now

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__) + '.py'

    def test_python_error(self):
        """check python error"""
        input_string = 'python -c "print(1\\2)" 2>&1'
        expected_result = '1          File "<string>", line 1\n2            print(1\\2)\n3                     ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
        self.assertEqual(gh.run(f'{input_string} | {self.script_module} -'), expected_result)

    def test_warnings(self):
        """test warning and warnings option"""
        input_string = 'bash: warning: here-document at line 119 delimited by end-of-file'
        expected_result = '1    >>> bash: warning: here-document at line 119 delimited by end-of-file <<<'
        empty_result = ''

        # Show warnings options
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --warning -'), expected_result)
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --warnings -'), expected_result)

        # Skip warnings option, not should retun nothing
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} -'), empty_result)
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --skip_warnings -'), empty_result)

    def test_context_lines(self):
        """test context lines"""
        input_string = 'python -c "print(1\\2)" 2>&1'
        result_context_1 = '3                     ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
        result_context_2 = '2            print(1\\2)\n3                     ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
        self.assertEqual(gh.run(f'{input_string} | {self.script_module} --context 1 -'), result_context_1)
        self.assertEqual(gh.run(f'{input_string} | {self.script_module} --context 2 -'), result_context_2)

    def test_no_asterisks(self):
        """test no asterisks option"""
        ## WORK-IN-PROGRESS

    def test_skip_ruby_lib(self):
        """test skip ruby lib and ruby options"""
        ## WORK-IN-PROGRESS

    def test_relaxed_strict(self):
        """test relaxed and strict options"""
        ## WORK-IN-PROGRESS

    def test_verbose(self):
        """test verbose option"""
        ## WORK-IN-PROGRESS


if __name__ == '__main__':
    unittest.main()
