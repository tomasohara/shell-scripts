#! /usr/bin/env python
#
# Tests for check_errors.py module

## TODO1: add standard mezcla test support (e.g., THE_MODULE; see mezcla/tests/template.py)
## TODO2: use self.run_script instead of gh.run

"""Tests for check_errors.py module (temporarily check_errors_conv.py)"""


# Standard packages
## OLD: Using pytest entirely with mezcla test template
# import unittest

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper, invoke_tests
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla import debug
from mezcla import file_utils as fu

# Importing script as module
## OLD: Importing script as a module
# SCRIPT = gh.resolve_path("check_errors.py")
try:
    from .. import check_errors_conv as THE_MODULE
    ## TODO: Change check_errors_conv to check_errors
except ImportError as e:
    debug.trace(3, f"Unable to import check_errors.py: {e}")
    THE_MODULE = None

# Environment Variables
RUN_SLOW_TESTS = system.getenv_bool("RUN_SLOW_TESTS", False, description="Run tests that can a while to run")

# Constants
TL = debug.TL

# --- 1. Error Pattern Matching ---

class TestErrorPatterns(TestWrapper):
    """Class for error pattern recognitions"""

    @pytest.mark.xfail
    def test_error_start_of_line(self):
        debug.trace(4, f"\ntest_error_start_of_line(); self={self}")
        input_txt = "ERROR: Divide by zero\nSecond line\n"
        datafile = gh.create_temp_file(contents=input_txt)
        expected = "       1 >>>Error: Something failed<<<\n       2 Second line\n"
        result = self.run_script(data_file=datafile)
        assert result == expected

    @pytest.mark.xfail
    def test_error_colon(self):
        debug.trace(4, f"\ntest_error_colon(); self={self}")
        pass

    @pytest.mark.xfail
    def test_error_brackets(self):
        debug.trace(4, f"\ntest_error_brackets(); self={self}")
        pass

    @pytest.mark.xfail
    def test_command_not_found(self):
        debug.trace(4, f"\ntest_command_not_found(); self={self}")
        pass

    @pytest.mark.xfail
    def test_cannot_switch_to_modules(self):
        debug.trace(4, f"\ntest_cannot_switch_to_modules(); self={self}")
        pass

    @pytest.mark.xfail
    def test_broken_pipe_strict(self):
        debug.trace(4, f"\ntest_broken_pipe_strict(); self={self}")
        pass

    @pytest.mark.xfail
    def test_broken_pipe_relaxed(self):
        debug.trace(4, f"\ntest_broken_pipe_relaxed(); self={self}")
        pass

    @pytest.mark.xfail
    def test_random_text(self):
        debug.trace(4, f"\ntest_random_text(); self={self}")
        pass

# --- 2. Warning/Info Pattern Matching ---

class TestWarningsAndInfo(TestWrapper):
    """Class for warning/info pattern recognitions"""

    @pytest.mark.xfail
    def test_warning_line(self):
        debug.trace(4, f"\ntest_warning_line(); self={self}")
        pass

    @pytest.mark.xfail
    def test_eq_warning_strict(self):
        debug.trace(4, f"\ntest_eq_warning_strict(); self={self}")
        pass

    @pytest.mark.xfail
    def test_skip_warnings_flag(self):
        debug.trace(4, f"\ntest_skip_warnings_flag(); self={self}")
        pass

    @pytest.mark.xfail
    def test_fyi_line(self):
        debug.trace(4, f"\ntest_fyi_line(); self={self}")
        pass

    @pytest.mark.xfail
    def test_information_line(self):
        debug.trace(4, f"\ntest_information_line(); self={self}")
        pass

# --- 3. Context Handling ---

class TestContextHandling(TestWrapper):
    """Class for context line extraction"""

    @pytest.mark.xfail
    def test_context_first_line(self):
        debug.trace(4, f"\ntest_context_first_line(); self={self}")
        pass

    @pytest.mark.xfail
    def test_context_middle_line(self):
        debug.trace(4, f"\ntest_context_middle_line(); self={self}")
        pass

    @pytest.mark.xfail
    def test_context_last_line(self):
        debug.trace(4, f"\ntest_context_last_line(); self={self}")
        pass

# --- 4. Golden Output ---

class TestGoldenOutput(TestWrapper):
    """Class for end-to-end output formatting"""

    @pytest.mark.xfail
    def test_mixed_sample_log(self):
        debug.trace(4, f"\ntest_mixed_sample_log(); self={self}")
        pass

# --- 5. Option/Flag Effects ---

class TestFlagsAndOptions(TestWrapper):
    """Class for CLI flag effects"""

    @pytest.mark.xfail
    def test_no_asterisks(self):
        debug.trace(4, f"\ntest_no_asterisks(); self={self}")
        pass

    @pytest.mark.xfail
    def test_skip_ruby_lib(self):
        debug.trace(4, f"\ntest_skip_ruby_lib(); self={self}")
        pass

    @pytest.mark.xfail
    def test_relaxed_strict(self):
        debug.trace(4, f"\ntest_relaxed_strict(); self={self}")
        pass

    @pytest.mark.xfail
    def test_verbose(self):
        debug.trace(4, f"\ntest_verbose(); self={self}")
        pass

## OLD: Multiple classes to be used for multiple types of tests
# class TestIt(TestWrapper):
#     """Class for testcase definition"""

#     def test_python_error(self):
#         """check python error"""
#         input_string    = 'python -c "print(1\\2)" 2>&1'
#         expected_result = '1          File "<string>", line 1\n2            print(1\\2)\n3                     ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
#         self.assertEqual(gh.run(f'{input_string} | {SCRIPT} -'), expected_result)


#     def test_warnings(self):
#         """test warning and warnings option"""
#         input_string    = 'bash: warning: here-document at line 119 delimited by end-of-file'
#         expected_result = '1    >>> bash: warning: here-document at line 119 delimited by end-of-file <<<'
#         empty_result    = ''

#         # Show warnings options        
#         self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --warning -'), expected_result)
#         self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --warnings -'), expected_result)

#         # Skip warnings option, not should retun nothing
#         self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} -'), empty_result)
#         self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --skip_warnings -'), empty_result)


#     def test_context_lines(self):
#         """test context lines"""
#         input_string     = 'python -c "print(1\\2)" 2>&1'
#         result_context_1 = '3                     ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
#         result_context_2 = '2            print(1\\2)\n3                     ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
#         self.assertEqual(gh.run(f'{input_string} | {SCRIPT} --context 1 -'), result_context_1)
#         self.assertEqual(gh.run(f'{input_string} | {SCRIPT} --context 2 -'), result_context_2)


#     @pytest.mark.xfail
#     def test_no_asterisks(self):
#         """test no asterisks option"""
#         ## WORK-IN-PROGRESS
#         assert(False)


#     @pytest.mark.xfail
#     def test_skip_ruby_lib(self):
#         """test skip ruby lib and ruby options"""
#         ## WORK-IN-PROGRESS
#         assert(False)


#     @pytest.mark.xfail
#     def test_relaxed_strict(self):
#         """test relaxed and strict options"""
#         ## WORK-IN-PROGRESS
#         assert(False)


#     @pytest.mark.xfail
#     def test_verbose(self):
#         """test verbose option"""
#         ## WORK-IN-PROGRESS
#         assert(False)


if __name__ == '__main__':
    ## OLD: Previous approaches using unittest
    # unittest.main()
    debug.trace_current_context()
    invoke_tests(__file__)
