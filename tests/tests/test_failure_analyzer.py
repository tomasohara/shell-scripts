#! /usr/bin/env python3
#
# Test(s) for ../failure_analyzer.py
#
#
# WAR STORIES & LESSONS LEARNED FROM DEBUGGING:
# ---------------------------------------------
# This test suite was hardened through several rounds of debugging. Here are the
# key takeaways that are now enshrined in our testing patterns:
#
#   - PATCH LEAKAGE IS REAL: Using `self.monkeypatch.setattr` can cause the
#     patch to "leak" into the test framework's `tearDown` phase, causing
#     cleanup commands (like `rm`) to fail.
#     >> SOLUTION: For mocking functions that raise errors, always prefer the
#        `@patch('module.function')` decorator on the test method. It is
#        automatically contained and cleaned up, preventing leakage.
#
#   - CLI PATHS MUST BE ABSOLUTE: A CLI test failed because the script, running
#     in a subprocess, couldn't resolve the relative path to the temp directory.
#     >> SOLUTION: The main script (`failure_analyzer.py`) was hardened to use
#        `os.path.abspath()` on the incoming `--results-dir` to remove all
#        ambiguity.
#
#   - PREDICTABLE OUTPUTS: The script originally wrote default reports to the
#     Current Working Directory, which is unpredictable.
#     >> SOLUTION: The script was changed to always write default reports
#        *inside* the results directory it is analyzing. This is predictable,
#        and the CLI test `test_cli_default_json_filename_creation` locks in
#        this correct behavior.
#
#
# PREREQUISITES FOR RUNNING:
# --------------------------
# - `pytest` must be installed.
# - The `mezcla` testing framework must be in the `PYTHONPATH`.
# - The `python-is-python3` package (or equivalent symlink) is expected by the
#   `mezcla` helpers to ensure `python` resolves correctly.
#

"""
Tests for the failure_analyzer module, following Tom's two-part strategy:
1.  API Tests: Directly test the run_failure_analysis helper function.
2.  CLI Tests: Use the run_script method to test command-line argument handling.
"""

import shutil
import os
import pytest
from unittest.mock import patch

# Local packages
from mezcla.unittest_wrapper import TestWrapper, invoke_tests
from mezcla import debug
from mezcla import system
from mezcla import glue_helpers as gh

# The module under test
import failure_analyzer as THE_MODULE


class TestFailureAnalyzer(TestWrapper):
    """Class for testcase definition, following the 'mezcla' testing style."""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    use_temp_base_dir = True
    python_exe = "python3"

    def setUp(self):
        """Set up a clean temporary directory for each test."""
        super().setUp()
        if system.file_exists(self.temp_base):
            shutil.rmtree(self.temp_base)
        system.create_directory(self.temp_base)

    # --------------------------------------------------------------------------
    # Part 1: API Tests (Testing the Helper Function Directly)
    # --------------------------------------------------------------------------

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_api_default_mode_aggregation(self):
        """API TEST: Verifies analysis and aggregation logic for default mode."""
        debug.trace(4, "TestFailureAnalyzer.test_api_default_mode_aggregation()")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp.out"), "not ok 1 - f1")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp"), "function f1_actual() {\n  cmd_a\n}")
        system.write_file(system.form_path(self.temp_base, "test2.outputpp.out"), "not ok 1 - f2")
        system.write_file(system.form_path(self.temp_base, "test2.outputpp"), "function f2_actual() {\n  cmd_b\n}")
        system.write_file(system.form_path(self.temp_base, "test3.outputpp.out"), "not ok 1 - f3")
        system.write_file(system.form_path(self.temp_base, "test3.outputpp"), "function f3_actual() {\n  cmd_a\n}")
        report_data = THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=False, show_table=False)
        self.do_assert(len(report_data) == 2, "Should aggregate into two commands")
        command, cmd_a_data = report_data[0]
        self.do_assert(command.strip() == 'cmd_a')
        self.do_assert(cmd_a_data['count'] == 2)
        self.do_assert(cmd_a_data['impact'] == 4)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_api_heuristic_mode_calculation(self):
        """API TEST: Verifies heuristic calculations."""
        debug.trace(4, "TestFailureAnalyzer.test_api_heuristic_mode_calculation()")
        self.monkeypatch.setattr(gh, "run", lambda *args, **kwargs: "macro-one\nmacro-two")
        log_content = (
            "ok 1\n+ macro-one\n\n==========\n"
            "not ok 2\n+ macro-one\n\n==========\n"
            "not ok 3\n+ macro-two"
        )
        system.write_file(system.form_path(self.temp_base, "test1.outputpp.out"), log_content)
        report_data = THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=True, show_table=False)
        self.do_assert(len(report_data) == 2)
        report_data.sort(key=lambda x: x['macro'])
        macro_one_stats = report_data[0]
        self.do_assert(macro_one_stats['macro'] == 'macro-one')
        self.do_assert(macro_one_stats['total'] == 2)
        self.do_assert(macro_one_stats['bad'] == 1)
        self.do_assert(macro_one_stats['pct_bad'] == 50.0)
        
    @pytest.mark.xfail                   # TODO: remove xfail
    def test_api_no_files_found(self):
        """API TEST: Ensures an empty list is returned for an empty directory."""
        self.monkeypatch.setattr(gh, "run", lambda *args, **kwargs: "macro-one")
        report_data = THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=False, show_table=False)
        self.do_assert(report_data == [])
        report_data_heuristic = THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=True, show_table=False)
        self.do_assert(report_data_heuristic == [])

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_api_no_failures_found(self):
        """API TEST: Ensures an empty report is generated if all tests pass."""
        debug.trace(4, "TestFailureAnalyzer.test_api_no_failures_found()")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp.out"), "ok 1 - f1\nok 2 - f2")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp"), "function f1_actual() {\n  cmd_a\n}")
        report_data = THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=False, show_table=False)
        self.do_assert(report_data == [], "Default mode should produce an empty list for passing tests")

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_api_recursive_directory_search(self):
        """API TEST: Verifies that the tool finds files in subdirectories."""
        debug.trace(4, "TestFailureAnalyzer.test_api_recursive_directory_search()")
        sub_dir = system.form_path(self.temp_base, "subdir")
        system.create_directory(sub_dir)
        system.write_file(system.form_path(self.temp_base, "test1.outputpp.out"), "not ok 1 - f1")
        system.write_file(system.form_path(self.temp_base, "test1.outputpp"), "function f1_actual() {\n  cmd_a\n}")
        system.write_file(system.form_path(sub_dir, "test2.outputpp.out"), "not ok 1 - f2")
        system.write_file(system.form_path(sub_dir, "test2.outputpp"), "function f2_actual() {\n  cmd_b\n}")
        report_data = THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=False, show_table=False)
        self.do_assert(len(report_data) == 2, "Should find files from both root and subdirectory")

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_api_special_characters_in_names(self):
        """API TEST: Verifies correct parsing of names with spaces and hyphens."""
        debug.trace(4, "TestFailureAnalyzer.test_api_special_characters_in_names()")
        system.write_file(system.form_path(self.temp_base, "spaces.outputpp.out"), "not ok 1 - my test with spaces")
        system.write_file(system.form_path(self.temp_base, "spaces.outputpp"), "function my_test_with_spaces_actual() {\n  cmd_with_space\n}")
        report_data = THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=False, show_table=False)
        self.do_assert(len(report_data) == 1 and report_data[0][0].strip() == "cmd_with_space")
        self.setUp()
        self.monkeypatch.setattr(gh, "run", lambda *args, **kwargs: "do-something-critical")
        system.write_file(system.form_path(self.temp_base, "hyphen.outputpp.out"), "not ok 1\n+ do-something-critical")
        report_data_h = THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=True, show_table=False)
        self.do_assert(len(report_data_h) == 1 and report_data_h[0]['macro'] == "do-something-critical")

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_api_heuristic_complex_correlation(self):
        """API TEST: Stress-tests the heuristic ranking with a tricky scenario."""
        debug.trace(4, "TestFailureAnalyzer.test_api_heuristic_complex_correlation()")
        self.monkeypatch.setattr(gh, "run", lambda *a, **kw: "macro-A\nmacro-B\nhelper-macro")
        log_content = (
            "not ok 1\n+ macro-A\n+ helper-macro\n" + "==========\n"
            "not ok 2\n+ macro-A\n+ helper-macro\n" + "==========\n"
            "not ok 3\n+ macro-A\n+ macro-B\n+ helper-macro\n" + "==========\n"
            "ok 4\n+ macro-A\n+ helper-macro\n" + "==========\n"
            "ok 5\n+ macro-B\n+ helper-macro\n" + "==========\n"
            "ok 6\n+ macro-B\n+ helper-macro\n"
        )
        system.write_file(system.form_path(self.temp_base, "complex.outputpp.out"), log_content)
        report_data = THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=True, show_table=False)
        self.do_assert(len(report_data) == 3)
        self.do_assert(report_data[0]['macro'] == 'macro-A', "macro-A should be ranked first")
        self.do_assert(report_data[1]['macro'] == 'helper-macro', "helper-macro should be ranked second")
        self.do_assert(report_data[2]['macro'] == 'macro-B', "macro-B should be ranked last")

    @pytest.mark.xfail                   # TODO: remove xfail
    @patch('mezcla.glue_helpers.run')
    def test_api_heuristic_show_macros_fails(self, mock_gh_run):
        """API TEST: Ensures graceful exit if 'show-macros-proper' command fails."""
        debug.trace(4, "TestFailureAnalyzer.test_api_heuristic_show_macros_fails()")
        
        # Configure the mock to raise an error when called
        mock_gh_run.side_effect = SystemError("Command failed")
        
        with pytest.raises(SystemExit) as e:
            THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=True, show_table=False)
        
        # Verify the script exited with the correct error code
        self.do_assert(e.value.code == 1)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_api_heuristic_no_macros_found(self):
        """API TEST: Ensures graceful exit if 'show-macros-proper' returns nothing."""
        debug.trace(4, "TestFailureAnalyzer.test_api_heuristic_no_macros_found()")
        self.monkeypatch.setattr(gh, "run", lambda *a, **kw: "")
        with pytest.raises(SystemExit) as e:
            THE_MODULE.run_failure_analysis(results_dir=self.temp_base, is_heuristic=True, show_table=False)
        self.do_assert(e.value.code == 1)

    # --------------------------------------------------------------------------
    # Part 2: CLI Tests (Testing Command-Line Argument Handling)
    # --------------------------------------------------------------------------

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_cli_heuristic_flag(self):
        """CLI TEST: Ensures the --heuristic flag activates the correct mode."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_heuristic_flag()")
        mock_bin_dir = system.form_path(self.temp_base, "mock_bin")
        system.create_directory(mock_bin_dir)
        mock_script_path = system.form_path(mock_bin_dir, "show-macros-proper")
        system.write_file(mock_script_path, "#!/bin/sh\necho 'macro-one'")
        os.chmod(mock_script_path, 0o755)
        env_vars = f"PATH={mock_bin_dir}{os.pathsep}{os.environ.get('PATH', '')}"
        system.write_file(system.form_path(self.temp_base, "test.outputpp.out"), "not ok 1")
        output = self.run_script(options=f'--results-dir {self.temp_base} --heuristic', env_options=env_vars)
        self.do_assert("Running Macro Failure Heuristic Analysis" in output)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_cli_json_filename_override(self):
        """CLI TEST: Ensures --json-filename overrides the default."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_json_filename_override()")
        system.write_file(system.form_path(self.temp_base, "test.outputpp.out"), "not ok 1 - f1")
        system.write_file(system.form_path(self.temp_base, "test.outputpp"), "function f1_actual() {\n cmd_a\n}")
        custom_report_path = system.form_path(self.temp_base, "my-custom-report.json")
        output = self.run_script(options=f'--results-dir {self.temp_base} --json-filename {custom_report_path}')
        self.do_assert(f"Writing full report to {custom_report_path}" in output)
        self.do_assert(system.file_exists(custom_report_path))

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_cli_missing_directory(self):
        """CLI TEST: Ensures the script exits gracefully if the directory is missing."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_missing_directory()")
        non_existent_dir = os.path.join(self.temp_base, "non_existent_dir")
        self.run_script(options=f'--results-dir {non_existent_dir}')
        log_contents = system.read_file(self.temp_file + ".log")
        self.do_assert(f"Error: Directory '{non_existent_dir}' does not exist" in log_contents)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_cli_default_json_filename_creation(self):
        """CLI TEST: Verifies correct default JSON report file creation."""
        debug.trace(4, "TestFailureAnalyzer.test_cli_default_json_filename_creation()")
        system.write_file(system.form_path(self.temp_base, "test.outputpp.out"), "not ok 1 - f1")
        system.write_file(system.form_path(self.temp_base, "test.outputpp"), "function f1_actual() {\n cmd_a\n}")
        self.run_script(options=f'--results-dir {self.temp_base}')
        # The default report should now be created *inside* the results dir.
        default_report = system.form_path(self.temp_base, "failure_analyzer_report.json")
        self.do_assert(system.file_exists(default_report), f"Default report '{default_report}' was not created")


# Standard entry point for the test runner
if __name__ == '__main__':
    debug.trace_current_context()
    invoke_tests(__file__)
    