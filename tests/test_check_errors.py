#! /usr/bin/env python
#
# Tests for check_errors.py module

## TODO1: add standard mezcla test support (e.g., THE_MODULE; see mezcla/tests/template.py)
## TODO2: use self.run_script instead of gh.run

"""Tests for check_errors.py module"""

# Standard packages
import unittest

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh

SCRIPT = gh.resolve_path("check_errors.py")

class TestIt(TestWrapper):
    """Class for testcase definition"""

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_python_error(self):
        """check python error"""
        input_string    = 'python -c "print(1\\2)" 2>&1'
        expected_result = '1          File "<string>", line 1\n2            print(1\\2)\n3                    ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
        assert (gh.run(f'{input_string} | {SCRIPT} -') == expected_result)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_warnings(self):
        """test warning and warnings option"""
        input_string    = 'bash: warning: here-document at line 119 delimited by end-of-file'
        expected_result = '1    >>> bash: warning: here-document at line 119 delimited by end-of-file <<<'
        empty_result    = ''

        # Show warnings options        
        assert (gh.run(f'echo "{input_string}" | {SCRIPT} --warning -').strip() == expected_result.strip())
        assert (gh.run(f'echo "{input_string}" | {SCRIPT} --warnings -').strip() == expected_result.strip())

        # Skip warnings option, not should retun nothing
        assert (gh.run(f'echo "{input_string}" | {SCRIPT} -') == empty_result)
        assert (gh.run(f'echo "{input_string}" | {SCRIPT} --skip-warnings -') == empty_result)

    def test_context_lines(self):
        """test context lines"""
        input_string     = 'python -c "print(1\\2)" 2>&1'
        result_context_1 = '3                    ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
        result_context_2 = '2            print(1\\2)\n3                    ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
        assert (gh.run(f'{input_string} | {SCRIPT} --context 1 -').strip() == result_context_1.strip())
        assert (gh.run(f'{input_string} | {SCRIPT} --context 2 -').strip() == result_context_2.strip())

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_no_asterisks(self):
        """test no asterisks option"""
        ## WORK-IN-PROGRESS
        assert(False)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_skip_ruby_lib(self):
        """test skip ruby lib and ruby options"""
        ## WORK-IN-PROGRESS
        assert(False)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_relaxed_strict(self):
        """test relaxed and strict options"""
        ## WORK-IN-PROGRESS
        assert(False)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_verbose(self):
        """test verbose option"""
        ## WORK-IN-PROGRESS
        assert(False)


if __name__ == '__main__':
    unittest.main()
