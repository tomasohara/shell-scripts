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
# TODO1 by Aviyan:
# - Review tests/template.py and add THE_MODULE, etc.
#

"""Tests for batspp_report module"""

# Standard packages
import unittest
import re
import os
import subprocess

# Installed packages
import pytest

# Local modules
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla.my_regex import my_re

# Note: Two references are used for the module to be tested:
#    THE_MODULE:                        global module object
#    TestIt.script_module:              path to file
try:
    import tests.batspp_report as THE_MODULE
except:
    system.print_exception_info("loading batspp_report.py")
    THE_MODULE = None
# Constants
# TODO2: get OUTPUT_DIR from THE_MODULE.OUTPUT_DIR
OUTPUT_DIR = system.getenv_text("OUTPUT_DIR", ".",
                                "Directory for output files such as .batspp test specs")
# note: script should either run in ./tests dir or define TEST_DIR
TEST_DIR = system.real_path(gh.dirname(__file__ or "."))
debug.assertion(TEST_DIR.endswith("tests"))

class TestBatsppReport(TestWrapper):
    ## NOTE: TestWrapper used above for sake of run_script()
    ##
    ## BAD: class TestBatsppReport(unittest.TestCase):
    """Class for testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    ## BAD:
    ## # TODO3: rework via tests/template.py (e.g., uses TestWrapper.run_script instead of gh.run)
    ## script = gh.resolve_path("batspp_report.py")
    temp = None


    ## BAD:
    ## def run_script(self, arguments):
    ##     """Simple version of TestWrapper.run_script that just runs script over ARGUMENTS"""
    ##     # note: overrides TEST_DIR to this dir (e.g., ~/bin/tests/tests)
    ##     ## TODO1: use run_script
    ##     debug.trace_fmt(5, "TestBatsppReport.run_script({args}) => {res!r}",
    ##                     args=arguments, res=result)
    ##    return result

    @pytest.mark.xfail
    def test_script_help(self):
        """Make sure script usage shown with --help"""
        debug.trace(4, f"TestBatsppReport.test_script_help(); self={self}")
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

def test_round3_precision():
    """Round helper should keep three decimal digits"""
    assert THE_MODULE.round3(1/3) == "0.333"

def test_load_thresholds_reads_yaml(tmp_path):
    """Threshold loader should return parsed YAML mapping"""
    yaml_file = tmp_path / "thresholds.yaml"
    yaml_file.write_text("minimum_score: 75\nsuites:\n  smoke: 90\n", encoding="utf-8")
    thresholds = THE_MODULE.load_thresholds(str(yaml_file))
    assert thresholds["minimum_score"] == 75
    assert thresholds["suites"]["smoke"] == 90

def test_outputpp_extension_constant():
    """Guard against regressions in outputpp naming"""
    assert THE_MODULE.OUTPUTPP == ".bats.outputpp"

def test_select_test_files_default_ignores_batspp():
    """By default only ipynb should be selected"""
    files = ["a.ipynb", "b.batspp", "note.txt"]
    ipynb_files, batspp_files, avoided_files = THE_MODULE.select_test_files(files)
    assert ipynb_files == ["a.ipynb"]
    assert batspp_files == []
    assert avoided_files == []

def test_select_test_files_optional_includes_batspp():
    """When enabled, direct batspp files should be selected too"""
    files = ["a.ipynb", "b.batspp", "NOBATSPP-c.ipynb", "NOBATSPP-d.batspp"]
    ipynb_files, batspp_files, avoided_files = THE_MODULE.select_test_files(
        files, include_batspp_files=True)
    assert ipynb_files == ["a.ipynb"]
    assert batspp_files == ["b.batspp"]
    assert avoided_files == ["NOBATSPP-c.ipynb", "NOBATSPP-d.batspp"]

def test_select_test_files_all_option_keeps_nobatspp():
    """--all behavior should keep NOBATSPP files"""
    files = ["NOBATSPP-c.ipynb", "NOBATSPP-d.batspp"]
    ipynb_files, batspp_files, avoided_files = THE_MODULE.select_test_files(
        files, all_option=True, include_batspp_files=True)
    assert ipynb_files == ["NOBATSPP-c.ipynb"]
    assert batspp_files == ["NOBATSPP-d.batspp"]
    assert avoided_files == []

def test_select_test_files_respects_regex():
    """Regex filtering should apply to both ipynb and direct batspp files"""
    files = ["git-aliases-tests-1.ipynb", "git-aliases-tests-1.batspp", "other.batspp"]
    ipynb_files, batspp_files, _ = THE_MODULE.select_test_files(
        files, test_regex=r"^git-aliases-tests-1", include_batspp_files=True)
    assert ipynb_files == ["git-aliases-tests-1.ipynb"]
    assert batspp_files == ["git-aliases-tests-1.batspp"]

def test_direct_batspp_temp_suite_macro_micro_differ(tmp_path):
    """Run a temp direct-batspp suite and validate divergent macro/micro means"""
    tests_dir = tmp_path / "defs"
    output_dir = tmp_path / "out"
    tests_dir.mkdir()
    output_dir.mkdir()

    file1 = tests_dir / "temp-a.batspp"
    file1.write_text(
        "# Global Setup\n"
        "$ shopt -s expand_aliases\n"
        "$ alias hi='echo hi'\n\n"
        "# Test a1\n"
        "$ hi\n"
        "hi\n\n"
        "# Test a2\n"
        "$ echo two\n"
        "two\n",
        encoding="utf-8")

    file2 = tests_dir / "temp-b.batspp"
    file2.write_text(
        "# Global Setup\n"
        "$ shopt -s expand_aliases\n"
        "$ alias hi='echo hi'\n\n"
        "# Test b1\n"
        "$ hi\n"
        "hi\n\n"
        "# Test b2 (intentional fail)\n"
        "$ echo three\n"
        "WRONG-three\n",
        encoding="utf-8")

    file3 = tests_dir / "temp-c.batspp"
    file3.write_text(
        "# Global Setup\n"
        "$ shopt -s expand_aliases\n"
        "$ alias hi='echo hi'\n\n"
        "# Test c1\n"
        "$ echo c1\n"
        "c1\n\n"
        "# Test c2\n"
        "$ echo c2\n"
        "c2\n\n"
        "# Test c3\n"
        "$ echo c3\n"
        "c3\n\n"
        "# Test c4\n"
        "$ echo c4\n"
        "c4\n\n"
        "# Test c5 (intentional fail)\n"
        "$ echo c5\n"
        "WRONG-c5\n\n"
        "# Test c6 (intentional fail)\n"
        "$ echo c6\n"
        "WRONG-c6\n",
        encoding="utf-8")

    env = os.environ.copy()
    env.update({
        "PYTHONPATH": f"..:.:{env.get('PYTHONPATH', '')}",
        "TEST_DIR": str(tests_dir),
        "OUTPUT_DIR": str(output_dir),
        "FORCE_RUN": "1",
        "UNDER_TESTING_VM": "1",
        "CLEAN_OUTPUT": "1",
        "DEBUG_LEVEL": "0",
    })
    result = subprocess.run(
        ["python3", "batspp_report.py", "--txt", "--all", "--batspp-files", "--force"],
        cwd=system.real_path("tests"),
        env=env,
        text=True,
        capture_output=True,
        check=False)
    assert result.returncode == 0, result.stdout + "\n" + result.stderr
    output = result.stdout + "\n" + result.stderr
    assert "Direct BATSPP Files Found: 3" in output
    assert "No. of BATSPP files (direct): 3" in output
    assert "(7/10)" in output
    macro_match = re.search(r"Macro success score:\s*([0-9.]+)%", output)
    micro_match = re.search(r"Micro success score:\s*([0-9.]+)%", output)
    assert macro_match and micro_match
    macro_score = float(macro_match.group(1))
    micro_score = float(micro_match.group(1))
    assert macro_score != micro_score
    assert macro_score > micro_score

@pytest.mark.xfail(reason="TODO: define exact rounding/format contract for summary percentages")
def test_direct_batspp_macro_format_is_fixed_precision():
    """Edge-case TODO: enforce exact decimal precision for macro/micro output"""
    assert False

@pytest.mark.xfail(reason="TODO: convert YAML parse failures to user-friendly script errors")
def test_load_thresholds_invalid_yaml_friendly_failure(tmp_path):
    """Edge-case TODO: malformed YAML should map to a friendly script-level error"""
    yaml_file = tmp_path / "thresholds-bad.yaml"
    yaml_file.write_text("minimum_score: [\n", encoding="utf-8")
    with pytest.raises(SystemExit, match=r"threshold"):
        THE_MODULE.load_thresholds(str(yaml_file))

@pytest.mark.xfail(reason="TODO: define explicit NaN policy for round3")
def test_round3_rejects_nan():
    """Edge-case TODO: define/implement NaN handling contract"""
    with pytest.raises(ValueError):
        THE_MODULE.round3(float("nan"))

@pytest.mark.xfail(reason="TODO: support case-insensitive test file extensions")
def test_select_test_files_case_insensitive_extensions():
    """Edge-case TODO: accept uppercase .IPYNB/.BATSPP names"""
    files = ["A.IPYNB", "B.BATSPP"]
    ipynb_files, batspp_files, _ = THE_MODULE.select_test_files(
        files, include_batspp_files=True)
    assert ipynb_files == ["A.IPYNB"]
    assert batspp_files == ["B.BATSPP"]


if __name__ == "__main__":
    unittest.main()
