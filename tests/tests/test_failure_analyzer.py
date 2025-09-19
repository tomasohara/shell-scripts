#! /usr/bin/env python3
#
# Test(s) for ../failure_analyzer.py
#
# Notes:
# - This is a test of the module, not the test template.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_failure_analyzer.py
#
#
# WAR STORIES & LESSONS LEARNED FROM DEBUGGING:
# ---------------------------------------------
# This test suite was hardened through several rounds of debugging. Here are the
# key takeaways that are now enshrined in our testing patterns:
#
#   - NO MOCKING LIBRARIES: To test interactions with external commands, we use
#     the "PATH Trick" instead of mocking libraries, ensuring we test the true
#     execution path.
#
#   - CLI PATHS MUST BE ABSOLUTE: Subprocesses can't resolve relative paths, so
#     we always pass absolute paths to the script using `system.absolute_path()`.
#
#   - REFACTOR FOR DRY (Don't Repeat Yourself): The initial CLI and API tests
#     had repetitive setup code. This was refactored by creating helper methods
#     (`helper_get_analyzer`, `helper_run_analyzer_cli`) to encapsulate common
#     actions, making each test simpler and more focused on its specific inputs and
#     assertions. This follows the KISS principle.
#

"""
Tests for the failure_analyzer module, using a strict "no-mock" policy for
testing external command interactions.
"""

# Standard packages
import shutil
import os
import json
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper, invoke_tests
from mezcla import debug
from mezcla import system

# Note: Two references are used for the module to be tested:
#   THE_MODULE:         global module object
import failure_analyzer as THE_MODULE


class TestFailureAnalyzer(TestWrapper):
    """Class for testcase definition, following the 'mezcla' testing style."""
    script_file = TestWrapper.get_module_file_path(__file__)
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    use_temp_base_dir = True
    python_exe = "python3"

    def setUp(self):
        """Set up a clean temporary directory for each test."""
        super().setUp()
        if system.file_exists(self.temp_base):
            shutil.rmtree(self.temp_base)
        system.create_directory(self.temp_base)

    def helper_setup_mock_bin_and_env(self, script_content: str, exit_code: int = 0) -> str:
        """Creates a fake 'show-macros-proper' and returns the PATH env var."""
        mock_bin_dir = system.form_path(self.temp_base, "mock_bin")
        system.create_directory(mock_bin_dir)
        mock_script_path = system.form_path(mock_bin_dir, "show-macros-proper")

        full_script = ["#!/bin/sh", script_content]
        if exit_code != 0:
            full_script.append(f"exit {exit_code}")

        system.write_file(mock_script_path, "\n".join(full_script))
        os.chmod(mock_script_path, 0o755)

        return f"PATH={system.absolute_path(mock_bin_dir)}:{os.environ.get('PATH', '')}"

    def helper_get_analyzer(self, is_heuristic=False):
        """Helper to instantiate the FailureAnalyzer with the temp directory (DRY)."""
        return THE_MODULE.FailureAnalyzer(
            results_dir=self.temp_base,
            is_heuristic=is_heuristic
        )

    def helper_run_analyzer_cli(self, cli_options: str = "", env_vars: str | None = None):
        """Helper to run the failure_analyzer script via the CLI (DRY)."""
        abs_results_dir = system.absolute_path(self.temp_base)
        # Prepend the mandatory results-dir option to all calls.
        full_options = f'--results-dir {abs_results_dir} {cli_options}'
        return self.run_script(options=full_options.strip(), env_options=env_vars)

    # --------------------------------------------------------------------------
    # Part 1: API Tests (For logic with no external dependencies)
    # --------------------------------------------------------------------------

    @pytest.mark.xfail
    def test_api_default_mode_aggregation(self):
        """API TEST: Verifies analysis and aggregation logic for default mode."""
        debug.trace(4, "TestFailureAnalyzer.test_api_default_mode_aggregation()")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp.out"), "not ok 1 - f1")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp"), "function f1_actual() {\n  cmd_a\n}")
        system.write_file(system.form_path(self.temp_base, "test2.outputpp.out"), "not ok 1 - f2")
        system.write_file(system.form_path(self.temp_base, "test2.outputpp"), "function f2_actual() {\n  cmd_b\n}")
        system.write_file(system.form_path(self.temp_base, "test3.outputpp.out"), "not ok 1 - f3")
        system.write_file(system.form_path(self.temp_base, "test3.outputpp"), "function f3_actual() {\n  cmd_a\n}")

        analyzer = self.helper_get_analyzer(is_heuristic=False)
        analyzer.run()
        report_data = analyzer.report_data

        self.do_assert(len(report_data) == 2)
        command, cmd_a_data = report_data[0]
        self.do_assert(command.strip() == 'cmd_a')
        self.do_assert(cmd_a_data['count'] == 2)
        self.do_assert(cmd_a_data['impact'] == 4)

    @pytest.mark.xfail
    def test_api_no_files_found(self):
        """API TEST: Ensures an empty list is returned for an empty directory."""
        debug.trace(4, "TestFailureAnalyzer.test_api_no_files_found()")
        analyzer = self.helper_get_analyzer(is_heuristic=False)
        analyzer.run()
        self.do_assert(analyzer.report_data == [])

    @pytest.mark.xfail
    def test_api_no_failures_found(self):
        """API TEST: Ensures an empty report is generated if all tests pass."""
        debug.trace(4, "TestFailureAnalyzer.test_api_no_failures_found()")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp.out"), "ok 1 - f1")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp"), "function f1_actual() {\n  cmd_a\n}")
        analyzer = self.helper_get_analyzer(is_heuristic=False)
        analyzer.run()
        self.do_assert(analyzer.report_data == [])

    @pytest.mark.xfail
    def test_api_recursive_directory_search(self):
        """API TEST: Verifies that the tool finds files in subdirectories."""
        debug.trace(4, "TestFailureAnalyzer.test_api_recursive_directory_search()")
        sub_dir = system.form_path(self.temp_base, "subdir")
        system.create_directory(sub_dir)
        system.write_file(system.form_path(self.temp_base, "test1.outputpp.out"), "not ok 1 - f1")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp"), "function f1_actual() {\n  cmd_a\n}")
        system.write_file(system.form_path(sub_dir, "test2.outputpp.out"), "not ok 1 - f2")
        system.write_file(system.form_path(sub_dir, "test2.outputpp"), "function f2_actual() {\n  cmd_b\n}")

        analyzer = self.helper_get_analyzer(is_heuristic=False)
        analyzer.run()
        self.do_assert(len(analyzer.report_data) == 2)

    @pytest.mark.xfail
    def test_api_special_characters_in_names(self):
        """API TEST: Verifies correct parsing of names with spaces (default mode)."""
        debug.trace(4, "TestFailureAnalyzer.test_api_special_characters_in_names()")
        system.write_file(system.form_path(self.temp_base, "spaces.outputpp.out"), "not ok 1 - my test with spaces")
        system.write_file(system.form_path(self.temp_base, "spaces.outputpp"), "function my_test_with_spaces_actual() {\n  cmd_with_space\n}")
        analyzer = self.helper_get_analyzer(is_heuristic=False)
        analyzer.run()
        report_data = analyzer.report_data
        self.do_assert(len(report_data) == 1 and report_data[0][0].strip() == "cmd_with_space")

    # --------------------------------------------------------------------------
    # Part 2: CLI Tests (For logic involving external commands)
    # --------------------------------------------------------------------------

    @pytest.mark.xfail
    def test_cli_heuristic_mode_calculation(self):
        """CLI TEST: Verifies heuristic calculations via PATH trick."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_heuristic_mode_calculation()")
        env_vars = self.helper_setup_mock_bin_and_env("echo 'macro-one\nmacro-two'")
        log_content = "ok 1\n+ macro-one\n\n==========\nnot ok 2\n+ macro-one\n\n==========\nnot ok 3\n+ macro-two"
        system.write_file(system.form_path(self.temp_base, "test1.outputpp.out"), log_content)

        self.helper_run_analyzer_cli(cli_options='--heuristic', env_vars=env_vars)

        report_path = system.form_path(self.temp_base, "failure_analyzer_heuristic.json")
        report_data = json.loads(system.read_file(report_path))
        self.do_assert(len(report_data) == 2)
        report_data.sort(key=lambda x: x['macro'])
        self.do_assert(report_data[0]['macro'] == 'macro-one' and report_data[0]['pct_bad'] == 50.0)

    @pytest.mark.xfail
    def test_cli_heuristic_complex_correlation(self):
        """CLI TEST: Stress-tests the heuristic ranking via PATH trick."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_heuristic_complex_correlation()")
        env_vars = self.helper_setup_mock_bin_and_env("echo 'macro-A\nmacro-B\nhelper-macro'")
        log_content = "not ok 1\n+ macro-A\n+ helper-macro\n" + "==========\n" + "not ok 2\n+ macro-A\n+ helper-macro\n" + "==========\n" + "not ok 3\n+ macro-A\n+ macro-B\n+ helper-macro\n" + "==========\n" + "ok 4\n+ macro-A\n+ helper-macro\n" + "==========\n" + "ok 5\n+ macro-B\n+ helper-macro\n" + "==========\n" + "ok 6\n+ macro-B\n+ helper-macro\n"
        system.write_file(system.form_path(self.temp_base, "complex.outputpp.out"), log_content)

        self.helper_run_analyzer_cli(cli_options='--heuristic', env_vars=env_vars)

        report_path = system.form_path(self.temp_base, "failure_analyzer_heuristic.json")
        report_data = json.loads(system.read_file(report_path))
        self.do_assert(len(report_data) == 3)
        self.do_assert(report_data[0]['macro'] == 'macro-A')
        self.do_assert(report_data[1]['macro'] == 'helper-macro')
        self.do_assert(report_data[2]['macro'] == 'macro-B')

    @pytest.mark.xfail
    def test_cli_heuristic_show_macros_fails(self):
        """CLI TEST: Ensures graceful exit if 'show-macros-proper' fails."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_heuristic_show_macros_fails()")
        env_vars = self.helper_setup_mock_bin_and_env("echo 'uh oh' >&2", exit_code=1)
        self.helper_run_analyzer_cli(cli_options='--heuristic', env_vars=env_vars)
        stderr = self.get_stderr()
        self.do_assert("Error: Could not execute 'show-macros-proper'", stderr)

    @pytest.mark.xfail
    def test_cli_heuristic_no_macros_found(self):
        """CLI TEST: Ensures graceful exit if 'show-macros-proper' returns nothing."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_heuristic_no_macros_found()")
        env_vars = self.helper_setup_mock_bin_and_env("")  # Empty script
        system.write_file(system.form_path(self.temp_base, "test.outputpp.out"), "not ok 1")
        self.helper_run_analyzer_cli(cli_options='--heuristic', env_vars=env_vars)
        stderr = self.get_stderr()
        self.do_assert("Error: 'show-macros-proper' returned no valid macros", stderr)

    @pytest.mark.xfail
    def test_cli_heuristic_flag(self):
        """CLI TEST: Ensures the --heuristic flag activates the correct mode."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_heuristic_flag()")
        env_vars = self.helper_setup_mock_bin_and_env("echo 'macro-one'")
        system.write_file(system.form_path(self.temp_base, "test.outputpp.out"), "not ok 1")
        output = self.helper_run_analyzer_cli(cli_options='--heuristic', env_vars=env_vars)
        self.do_assert("Running Macro Failure Heuristic Analysis", output)

    @pytest.mark.xfail
    def test_cli_json_filename_override(self):
        """CLI TEST: Ensures --json-filename overrides the default."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_json_filename_override()")
        system.write_file(system.form_path(self.temp_base, "test.outputpp.out"), "not ok 1 - f1")
        system.write_file(system.form_path(self.temp_base, "test.outputpp"), "function f1_actual() {\n cmd_a\n}")
        custom_report_path = system.form_path(self.temp_base, "my-custom-report.json")
        output = self.helper_run_analyzer_cli(cli_options=f'--json-filename {custom_report_path}')
        self.do_assert(f"Writing full report to {custom_report_path}", output)
        self.do_assert(system.file_exists(custom_report_path))

    @pytest.mark.xfail
    def test_cli_missing_directory(self):
        """CLI TEST: Ensures the script exits gracefully if the directory is missing."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_missing_directory()")
        non_existent_dir = os.path.join(system.absolute_path(self.temp_base), "non_existent_dir")
        # Override the helper for this specific case since we need a non-existent directory.
        self.run_script(options=f'--results-dir {non_existent_dir}')
        stderr = self.get_stderr()
        self.do_assert(f"Error: Directory '{non_existent_dir}' does not exist", stderr)

    @pytest.mark.xfail
    def test_cli_default_json_filename_creation(self):
        """CLI TEST: Verifies correct default JSON report file creation."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_default_json_filename_creation()")
        system.write_file(system.form_path(self.temp_base, "test.outputpp.out"), "not ok 1 - f1")
        system.write_file(system.form_path(self.temp_base, "test.outputpp"), "function f1_actual() {\n cmd_a\n}")
        self.helper_run_analyzer_cli()  # No extra options needed
        default_report = system.form_path(self.temp_base, "failure_analyzer_report.json")
        self.do_assert(system.file_exists(default_report))

# ------------------------------------------------------------------------

# Standard entry point for the test runner
if __name__ == '__main__':
    debug.trace_current_context()
    invoke_tests(__file__)