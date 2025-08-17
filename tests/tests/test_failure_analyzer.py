#! /usr/bin/env python3
#
# Test(s) for ../failure_analyzer.py
#
# Notes:
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_failure_analyzer.py
#

"""Tests for failure_analyzer module"""

# Standard packages
from pathlib import Path

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper, invoke_tests
from mezcla import debug
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	                global module object
import failure_analyzer as THE_MODULE


class TestFailureAnalyzer(TestWrapper):
    # pylint: disable=protected-access
    """
    Class for testcase definition.
    Protected-access is disabled because white-box testing of internal
    methods is the explicit goal here.
    """
    script_module = TestWrapper.derive_tested_module_name(__file__)
    use_temp_base_dir = True

    @pytest.mark.xfail
    def test_analyze_test_run_happy_path(self):
        """
        Tests the _analyze_test_run method for the standard success case.
        Verifies parsing a single failure and extracting the command block.
        """
        debug.trace(4, "TestFailureAnalyzer.test_analyze_test_run_happy_path()")

        # Setup
        app = THE_MODULE.Script()
        app.results_dir = self.temp_base
        system.write_file(system.form_path(self.temp_base, "test1.outputpp.out"), "not ok 1 - a test has failed")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp"), """
function a_test_has_failed_actual() {
    the_suspect_command --with-args
}
""")
        # Run Test
        sorted_failures = app._analyze_test_run()

        # Assert
        self.do_assert(len(sorted_failures) == 1, "Should find exactly one failure group")
        command, data = sorted_failures[0]
        self.do_assert("the_suspect_command --with-args" in command)
        self.do_assert(data['count'] == 1)
        self.do_assert("test1.batspp" in data['sources'])

    @pytest.mark.xfail
    def test_analyze_test_run_no_output_files(self):
        """
        Tests the _analyze_test_run method's behavior when no
        *.outputpp.out files are found in the results directory.
        """
        debug.trace(4, "TestFailureAnalyzer.test_analyze_test_run_no_output_files()")

        # Setup
        app = THE_MODULE.Script()
        app.results_dir = self.temp_base

        # Run Test
        sorted_failures = app._analyze_test_run()

        # Assert
        self.do_assert(sorted_failures == [], "The result should be an empty list when no files are found")

    @pytest.mark.xfail
    def test_analyze_test_run_aggregation(self):
        """
        Tests the aggregation logic of _analyze_test_run.
        A single command that fails in multiple tests should be aggregated
        into one entry with a higher count and impact score.
        """
        debug.trace(4, "TestFailureAnalyzer.test_analyze_test_run_aggregation()")

        # Setup
        app = THE_MODULE.Script()
        app.results_dir = self.temp_base
        system.write_file(system.form_path(self.temp_base, "test1.outputpp.out"), "not ok 1 - failure one")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp"), "function failure_one_actual() { common_failing_command }")

        system.write_file(system.form_path(self.temp_base, "test2.outputpp.out"), "not ok 1 - failure two")
        system.write_file(system.form_path(self.temp_base, "test2.outputpp"), "function failure_two_actual() { common_failing_command }")

        # Run Test
        sorted_failures = app._analyze_test_run()

        # Assert
        self.do_assert(len(sorted_failures) == 1, "Failures for the same command should be aggregated")
        command, data = sorted_failures[0]
        self.do_assert("common_failing_command" in command)
        self.do_assert(data['count'] == 2, "Aggregated count should be 2")
        self.do_assert(len(data['sources']) == 2, "It should list two different source files")
        self.do_assert(data['impact'] == 4, "Impact score should be count * number of sources (2*2)")

    @pytest.mark.xfail
    def test_find_failed_tests(self):
        """
        Tests the _find_failed_tests helper method.
        Verifies it correctly extracts test names from 'not ok' lines,
        ignoring 'ok' lines, comments, and other noise.
        """
        debug.trace(4, "TestFailureAnalyzer.test_find_failed_tests()")

        # Setup
        app = THE_MODULE.Script()
        log_content = """
ok 1 - this one passed
not ok 2 - this is a failure
# some comment
not ok 3 - another failure # with a trailing comment
        """
        log_file = system.form_path(self.temp_base, "test.outputpp.out")
        system.write_file(log_file, log_content)

        # Run Test
        failed_tests = app._find_failed_tests(Path(log_file))

        # Assert
        self.do_assert(len(failed_tests) == 2)
        self.do_assert(set(failed_tests) == {"this is a failure", "another failure"})

    @pytest.mark.xfail
    def test_extract_from_generated_script(self):
        """
        Tests the _extract_from_generated_script helper method.
        Verifies it can find and extract the body of a specific function
        from a generated script file.
        """
        debug.trace(4, "TestFailureAnalyzer.test_extract_from_generated_script()")

        # Setup
        app = THE_MODULE.Script()
        script_content = """
function some_other_function_actual() {
    dont_find_this
}
function my_real_test_actual() {
    # a comment to ignore
    this_is_the_command --to --extract
}
"""
        script_file = system.form_path(self.temp_base, "test.outputpp")
        system.write_file(script_file, script_content)

        # Run Test
        extracted_command = app._extract_from_generated_script(Path(script_file), "my real test")

        # Assert
        self.do_assert(extracted_command is not None)
        self.do_assert(extracted_command == "this_is_the_command --to --extract")

        # Run Test for a non-existent function
        extracted_command_none = app._extract_from_generated_script(Path(script_file), "non_existent_test")
        self.do_assert(extracted_command_none is None, "Should return None for a function that doesn't exist")


#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    invoke_tests(__file__)
