#! /usr/bin/env python
#
# Simple tests for batspp_report.py.
#
# Note:
# - *** The --force option is dangerous: it must be specified via the environment. ***
# - This should just test 2 or 3 jupyter files with a small number of commands.
#
# TODO2 by Aviyan:
# - Avoid using array.pop(0): instead use indexing (e.g., array[0] or array[1:])
# - Review tests/template.py and add THE_MODULE, etc.
#

"""Tests for batspp_report module"""

# Standard packages
import unittest
import re

# Installed packages
import pytest

# Local modules
## TODO: from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla.my_regex import my_re

# Constants
# TODO2: get OUTPUT_DIR from THE_MODULE.OUTPUT_DIR
OUTPUT_DIR = system.getenv_text("OUTPUT_DIR", ".",
                                "Directory for output files such as .batspp test specs")
# note: script should either run in ./tests dir or define TEST_DIR
TEST_DIR = system.real_path(gh.dirname(__file__ or "."))
debug.assertion(TEST_DIR.endswith("tests"))

## OLD: class TestBatsppReport(TestWrapper):
## NOTE: TestWrapper used above for sake of run_script()
##
class TestBatsppReport(unittest.TestCase):
    """Class for testcase definition"""
    # TODO3: rework via tests/template.py (e.g., uses TestWrapper.run_script instead of gh.run)
    script = gh.resolve_path("batspp_report.py")
    temp = None

    def run_script(self, arguments):
        """Simple version of TestWrapper.run_script that just runs script over ARGUMENTS"""
        # note: overrides TEST_DIR to this dir (e.g., ~/bin/tests/tests)
        result = gh.run(f"TEST_DIR={TEST_DIR} {self.script} {arguments}")
        debug.trace_fmt(5, "TestBatsppReport.run_script({args}) => {res!r}",
                        args=arguments, res=result)
        return result

    def test_script_help(self):
        """Make sure script usage shown with --help"""
        result = self.run_script("--help")
        assert(my_re.search(r"Test.*BatsPP.*Bash", result))
    
    @pytest.mark.xfail
    def test_txt_report_format(self):
        """Tests txt report format"""
        debug.trace(4, f"TestBatsppReport.test_txt_report_format(); self={self}")
        txt_report_format = r"(\d+) out of (\d+) successful"
        ## OLD: txt_report_from_dir = gh.read_lines("txt-reports/hello-world.txt")
        report_file = gh.form_path(OUTPUT_DIR, "txt-reports", "hello-world.txt")
        txt_report_from_dir = gh.read_lines(report_file)
        txt_report_search_cond = [
            "True" for line in txt_report_from_dir if re.search(txt_report_format, line)
        ].pop(0)
        # TODO/(BUG?): my_re.search returns NoneType, find a way to return bool
        self.assertEqual(txt_report_search_cond, "True")

    @pytest.mark.xfail
    def test_no_report_option(self):
        """Tests no report option"""
        debug.trace(4, f"TestBatsppReport.test_no_report_option(); self={self}")
        self.temp = gh.create_temp_file(contents="")
        self.run_script(f"--no > {self.temp}")
        no_report_command_output = gh.read_lines(self.temp)
        no_report_indicator = ">> SKIPPING BATSPP CHECK (-n ARGUMENT PROVIDED)"
        ## OLD
        ## # LACKING: assertEqual cannot compare other types than "str"
        ## is_no_report = str(
        ##     True if no_report_indicator in no_report_command_output else False
        ## )
        ## self.assertEqual(is_no_report, "True")
        is_no_report = (no_report_indicator in no_report_command_output)
        self.assertTrue(is_no_report)

    @pytest.mark.xfail
    def test_count_avoided_testfiles(self):
        """Tests counts of avoided testfiles"""
        # Atleast one test has "NOBATSPP" suffix
        # TODO: Use my_re instead of re for pattern searching
        debug.trace(4, f"TestBatsppReport.test_count_avoided_testfiles(); self={self}")
        avoided_pattern = r"No\. of AVOIDED testfiles: (\d+)"
        self.temp = gh.create_temp_file(contents="")
        self.run_script(f"--no > {self.temp}")
        command_output = gh.read_lines(self.temp)
        count_avoided_testfiles_statement = [
            line for line in command_output if re.search(avoided_pattern, line)
        ].pop(0)
        count_avoided_testfiles = int(count_avoided_testfiles_statement[-1])
        is_avoided_testfiles = "True" if count_avoided_testfiles != 0 else "False"
        self.assertEqual(is_avoided_testfiles, "True")

    @pytest.mark.xfail
    def test_count_all_testfiles(self):
        """Tests counts of all testfiles"""
        debug.trace(4, f"TestBatsppReport.test_count_all_testfiles(); self={self}")
        # Complement process of test_count_avoided_testfiles
        avoided_pattern = r"No\. of AVOIDED testfiles: (\d+)"
        self.temp = gh.create_temp_file(contents="")
        self.run_script(f"--no --all > {self.temp}")
        command_output = gh.read_lines(self.temp)
        count_avoided_testfiles_statement = [
            line for line in command_output if my_re.search(avoided_pattern, line)
        ].pop(0)
        count_avoided_testfiles = int(count_avoided_testfiles_statement[-1])
        is_avoided_testfiles = "True" if count_avoided_testfiles == 0 else "False"
        self.assertEqual(is_avoided_testfiles, "True")

    @pytest.mark.xfail
    def test_warnings(self):
        """Tests warning generated by script"""
        debug.trace(4, f"TestBatsppReport.test_warnings(); self={self}")
        warning_message = "Error: running under admin account requires --force option"
        self.temp = gh.create_temp_file(contents="")
        self.run_script(f"--no > {self.temp} 2>&1")
        command_output = gh.read_lines(self.temp)
        self.assertEqual(command_output.pop(0), warning_message)

    @pytest.mark.xfail
    def test_kcov_reports(self):
        """Tests kcov report generation"""
        debug.trace(4, f"TestBatsppReport.test_kcov_reports(); self={self}")
        ## WORK-IN-PROGRESS
        assert (False)

    @pytest.mark.xfail
    def test_switch_option(self):
        """Tests --switch options in script"""
        debug.trace(4, f"TestBatsppReport.test_switch_option(); self={self}")
        switch_pattern = "simple_batspp.py used:"
        self.temp = gh.create_temp_file(contents="")
        self.run_script(f"--switch > {self.temp}")
        command_output = gh.read_lines(self.temp)
        switch_statement = [
            line for line in command_output if re.search(switch_pattern, line)
        ].pop(0)
        switch_statement_result = (
            switch_statement[switch_statement.rfind(" ") + 1 :]
            if " " in switch_statement
            else switch_statement
        )
        self.assertEqual(switch_statement_result, "True")

    @pytest.mark.xfail
    def test_env_variables(self):
        """Tests environment variables in script"""
        debug.trace(4, f"TestBatsppReport.test_env_variables(); self={self}")
        assert (False)


if __name__ == "__main__":
    unittest.main()
