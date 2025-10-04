#! /usr/bin/env python3
#
# Test(s) for ../generate_macro_heatmap.py
#
# Notes:
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_generate_macro_heatmap.py
#

"""Tests for generate_macro_heatmap module"""

# Standard packages
import json
import re

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper, invoke_tests
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla import debug

# Module to be tested
import generate_macro_heatmap as THE_MODULE

# Mock Data
MOCK_COVERAGE_DATA = [
    {"macro": "run-python-script", "percent_covered": 100.0, "covered_lines": 5, "total_lines": 5, "status": "well_tested"},
    {"macro": "tpo-common-util", "percent_covered": 50.0, "covered_lines": 1, "total_lines": 2, "status": "insufficiently_tested"},
    {"macro": "another-func", "percent_covered": 0.0, "covered_lines": 0, "total_lines": 3, "status": "untested"}
]

MOCK_FAILURE_DATA = [
    {"macro": "run-python-script", "total": 60, "bad": 0, "pct_bad": 0.0, "failing_in_files": []},
    {"macro": "tpo-common-util", "total": 5, "bad": 2, "pct_bad": 40.0, "failing_in_files": ["/path/to/test_one.sh", "/path/to/test_two.sh"]}
]

class TestAPI(TestWrapper):
    """Class for API test case definitions (HeatmapGenerator)"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    @pytest.mark.xfail
    def setUp(self):
        """Setup mock source directory and files for API tests"""
        super().setUp()
        self.mock_source_dir = self.get_temp_dir()
        
        # Create mock alias files
        content1 = """
# This is a comment
function run-python-script() {
    echo "running python"
}

alias tpo-common-util='echo "util"'
"""
        system.write_file(gh.form_path(self.mock_source_dir, "tomohara-proper-aliases.bash"), content1)

        content2 = """
function another-func() {
    echo "another"
}
# This function will be picked up by the regex
function not-a-macro() {
    echo "not a macro"
}
alias an-untested-alias=ls
"""
        system.write_file(gh.form_path(self.mock_source_dir, "tomohara-extra-aliases.bash"), content2)
        
        # File that should be ignored
        system.write_file(gh.form_path(self.mock_source_dir, "not-aliases.bash"), "alias x=y")
        
        self.helper = THE_MODULE.HeatmapGenerator(source_dir=self.mock_source_dir)

    @pytest.mark.xfail
    def test_load_json_valid(self):
        """Ensure load_json_file handles a valid file"""
        debug.trace(4, "test_load_json_valid()")
        valid_json_path = self.create_temp_file(json.dumps([{"a": 1}]))
        data = self.helper.load_json_file(valid_json_path)
        assert data == [{"a": 1}]

    @pytest.mark.xfail
    def test_load_json_malformed(self):
        """Ensure load_json_file handles a malformed file"""
        debug.trace(4, "test_load_json_malformed()")
        captured_traces = []
        self.monkeypatch.setattr(THE_MODULE.debug, 'trace', lambda *args, **kwargs: captured_traces.append(args))
        
        bad_json_path = self.create_temp_file('{"a": 1,}')
        data = self.helper.load_json_file(bad_json_path)
        
        assert data == []
        assert any("Error: Could not parse JSON" in call[1] for call in captured_traces)

    @pytest.mark.xfail
    def test_load_json_empty(self):
        """Ensure load_json_file handles an empty file"""
        debug.trace(4, "test_load_json_empty()")
        captured_traces = []
        self.monkeypatch.setattr(THE_MODULE.debug, 'trace', lambda *args, **kwargs: captured_traces.append(args))

        empty_file_path = self.get_temp_file()
        system.write_file(empty_file_path, "", skip_newline=True) # Ensure 0-byte file
        data = self.helper.load_json_file(empty_file_path)

        assert data == []
        assert any("Warning: File is empty" in call[1] for call in captured_traces)

    @pytest.mark.xfail
    def test_load_json_nonexistent(self):
        """Ensure load_json_file handles a non-existent file"""
        debug.trace(4, "test_load_json_nonexistent()")
        data = self.helper.load_json_file("non-existent-file.json")
        assert data == []

    @pytest.mark.xfail
    def test_get_all_macros(self):
        """Ensure get_all_macros correctly finds functions and aliases"""
        debug.trace(4, "test_get_all_macros()")
        
        macros = self.helper.get_all_macros()
        
        assert len(macros) == 5
        assert "run-python-script" in macros
        assert "tpo-common-util" in macros
        assert "another-func" in macros
        assert "an-untested-alias" in macros
        assert "not-a-macro" in macros
        assert "x" not in macros

    @pytest.mark.xfail
    def test_get_all_macros_no_files(self):
        """Ensure get_all_macros handles no matching files found"""
        debug.trace(4, "test_get_all_macros_no_files()")
        captured_traces = []
        self.monkeypatch.setattr(THE_MODULE.debug, 'trace', lambda *args, **kwargs: captured_traces.append(args))
        
        empty_dir = self.get_temp_dir()
        helper = THE_MODULE.HeatmapGenerator(source_dir=empty_dir)
        macros = helper.get_all_macros()

        assert not macros
        assert any("Warning: No files matching" in call[1] for call in captured_traces)

    @pytest.mark.xfail
    def test_merge_data(self):
        """Ensure merge_data correctly combines all data sources"""
        debug.trace(4, "test_merge_data()")
        
        all_macros = self.helper.get_all_macros()
        merged = self.helper.merge_data(all_macros, MOCK_COVERAGE_DATA, MOCK_FAILURE_DATA)
        
        merged_map = {item['macro']: item for item in merged}
        
        assert len(merged_map) == 5

    @pytest.mark.xfail
    def test_generate_tsv_report(self):
        """Ensure the detailed TSV report is formatted correctly"""
        debug.trace(4, "test_generate_tsv_report()")
        all_macros = self.helper.get_all_macros()
        merged_data = self.helper.merge_data(all_macros, MOCK_COVERAGE_DATA, MOCK_FAILURE_DATA)
        
        tsv_output = self.helper.generate_tsv_report(merged_data)
        
        assert "Macro\tStatus\tCoveragePct\tTotalUses\tFailingHits\tFailureRatePct\tType\tDefinitionFile" in tsv_output
        assert "run-python-script\twell_tested\t100.00" in tsv_output

    @pytest.mark.xfail
    def test_generate_tsv_heatmap_report(self):
        """Ensure the summary TSV heatmap is formatted correctly"""
        debug.trace(4, "test_generate_tsv_heatmap_report()")
        all_macros = self.helper.get_all_macros()
        merged_data = self.helper.merge_data(all_macros, MOCK_COVERAGE_DATA, MOCK_FAILURE_DATA)
        
        tsv_output = self.helper.generate_tsv_heatmap_report(merged_data)
        lines = tsv_output.splitlines()
        
        assert lines[0] == "SourceFile\tUsageBin\tStatus\tMacroCount"
        assert "tomohara-proper-aliases.bash\tHigh (50+)\twell_tested\t1" in lines

    @pytest.mark.xfail
    def test_generate_unified_report(self):
        """Ensure the HTML report is generated without errors"""
        debug.trace(4, "test_generate_unified_report()")
        output_path = self.get_temp_file("report.html")
        self.helper.output_file = output_path
        
        all_macros = self.helper.get_all_macros()
        merged_data = self.helper.merge_data(all_macros, MOCK_COVERAGE_DATA, MOCK_FAILURE_DATA)
        
        self.helper.generate_unified_report(merged_data)
        
        assert system.non_empty_file(output_path)
        html_content = system.read_entire_file(output_path)
        
        assert "<!DOCTYPE html>" in html_content
        assert "Unified Macro Coverage Report" in html_content
        
        # Correctly check for the rendered HTML structure
        expected_count_html = 'Analyzed <span class="font-bold text-blue-600">5</span> macros.'
        # Normalize whitespace for a more robust check
        normalized_html_content = re.sub(r'\s+', ' ', html_content)
        normalized_expected = re.sub(r'\s+', ' ', expected_count_html)
        assert normalized_expected in normalized_html_content
        
        assert "run-python-script" in html_content


class TestCLI(TestWrapper):
    """Class for CLI test case definitions"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    @pytest.mark.xfail
    def setUp(self):
        """Set up temporary files for CLI tests"""
        super().setUp()
        self.mock_source_dir = self.get_temp_dir()
        system.write_file(gh.form_path(self.mock_source_dir, "tomohara-aliases.bash"), "function my-macro() {}")
        
        self.coverage_file = self.create_temp_file(json.dumps(MOCK_COVERAGE_DATA))
        self.failure_file = self.create_temp_file(json.dumps(MOCK_FAILURE_DATA))
        
        self.base_args = [
            '--' + THE_MODULE.COVERAGE_REPORT, self.coverage_file,
            '--' + THE_MODULE.FAILURE_REPORT, self.failure_file,
            '--' + THE_MODULE.SOURCE_DIR, self.mock_source_dir,
        ]

    @pytest.mark.xfail
    def test_cli_help(self):
        """Ensure --help switch works"""
        debug.trace(4, "test_cli_help()")
        stdout = self.run_script('--help')
        assert "Creates a unified report for shell macro coverage." in stdout
        assert "Path to the JSON coverage report" in stdout

    @pytest.mark.xfail
    def test_cli_missing_args(self):
        """Ensure script fails with missing required arguments"""
        debug.trace(4, "test_cli_missing_args()")
        args = ['--' + THE_MODULE.COVERAGE_REPORT, self.coverage_file]
        log_file = self.get_temp_file("log")
        self.run_script(' '.join(args), log_file=log_file)
        log_content = system.read_entire_file(log_file)
        assert "Failure report path must be provided." in log_content

    @pytest.mark.xfail
    def test_cli_default_tsv_heatmap_output(self):
        """Ensure default output is the TSV heatmap to stdout"""
        debug.trace(4, "test_cli_default_tsv_heatmap_output()")
        stdout = self.run_script(' '.join(self.base_args))
        assert "SourceFile\tUsageBin\tStatus\tMacroCount" in stdout
        assert "tomohara-aliases.bash\tUnused (0)\tnot_tested\t1" in stdout

    @pytest.mark.xfail
    def test_cli_extended_tsv_output(self):
        """Ensure EXTENDED_MACROS_OUTPUT env var produces detailed TSV"""
        debug.trace(4, "test_cli_extended_tsv_output()")
        self.monkeypatch.setenv("EXTENDED_MACROS_OUTPUT", "true")
        stdout = self.run_script(' '.join(self.base_args))
        assert "Macro\tStatus\tCoveragePct\tTotalUses" in stdout
        assert "my-macro\tnot_tested\tN/A" in stdout

    @pytest.mark.xfail
    def test_cli_tsv_file_output(self):
        """Ensure --output-tsv writes to a file"""
        debug.trace(4, "test_cli_tsv_file_output()")
        output_file = self.get_temp_file("output.tsv")
        args = self.base_args + ['--' + THE_MODULE.OUTPUT_TSV, output_file]
        
        self.run_script(' '.join(args))
        
        assert self.get_stdout() == ""
        assert system.non_empty_file(output_file)
        content = system.read_entire_file(output_file)
        assert "SourceFile\tUsageBin\tStatus\tMacroCount" in content

    @pytest.mark.xfail
    def test_cli_web_file_output(self):
        """Ensure --output-web writes an HTML file"""
        debug.trace(4, "test_cli_web_file_output()")
        output_file = self.get_temp_file("report.html")
        args = self.base_args + ['--' + THE_MODULE.OUTPUT_WEB, output_file]
        
        self.run_script(' '.join(args))
        
        assert self.get_stdout() == ""
        assert system.non_empty_file(output_file)
        content = system.read_entire_file(output_file)
        assert "<!DOCTYPE html>" in content
        assert "Unified Macro Coverage Report" in content

    @pytest.mark.xfail
    def test_main_function(self):
        """Ensure main function can be called"""
        debug.trace(4, "test_main_function()")
        self.monkeypatch.setattr(system.sys, 'argv', ['generate_macro_heatmap.py'] + self.base_args)
        THE_MODULE.main()
        stdout = self.get_stdout()
        assert "SourceFile\tUsageBin\tStatus\tMacroCount" in stdout

if __name__ == '__main__':
    debug.trace_current_context()
    invoke_tests(__file__)
