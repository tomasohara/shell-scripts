#! /usr/bin/env python
#
# Simple tests for automate_ipynb.py
#
# Note:
# - *** The --force option is dangerous: it must be specified via the environment. ***
# - This should just test 2 or 3 jupyter files with a small number of commands.

"""Tests for automate_ipynb module"""

# Standard Packages
import unittest

# Installed Packages
import pytest
from selenium import webdriver

# Local Modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla.my_regex import my_re

import automate_ipynb as THE_MODULE

# Constants
LOCALHOST_REGEX = r"http://127\.0\.0\.1:8888/"

# TODO2: get OUTPUT_DIR from THE_MODULE.OUTPUT_DIR
OUTPUT_DIR = system.getenv_text("OUTPUT_DIR", ".",
                                "Directory for output files such as .batspp test specs")
# note: script should either run in ./tests dir or define TEST_DIR
TEST_DIR = system.real_path(gh.dirname(__file__ or "."))
debug.assertion(TEST_DIR.endswith("tests"))

class TestAutomateIPYNB(unittest.TestCase):
    """Class for testcase definition"""
    script = gh.resolve_path("automate_batspp.py")
    temp = None

    def run_script(self, arguments):
        """Simple version of TestCase.run_script that just runs script over ARGUMENTS"""
        # note: overrides TEST_DIR to this dir (e.g., ~/bin/tests/tests)
        result = gh.run(f"TEST_DIR={TEST_DIR} {self.script} {arguments}")
        debug.trace_fmt(5, "TestAutomateIPYNB.run_script({args}) => {res!r}",
                        args=arguments, res=result)
        return result

    def test_script_help(self):
        """Make sure script usage shown with --help"""
        result = self.run_script("--help")
        debug.trace(4, f"TestBatsppReport.test_script_help(); self={self}")
        assert(my_re.search(r"automate", result))

    def test_arg_opt_first(self):
        """Test case for argument option 'first'"""
        output = gh.run("AUTOMATION_DURATION_RERUN=1 python3 automate_ipynb.py --first 3").split("\n")
        debug.trace(4, f"TestBatsppReport.test_arg_opt_first(); self={self}")
        count = sum(1 for _ in output if my_re.search(LOCALHOST_REGEX, _))
        assert count == 3
        
    def test_arg_opt_include(self):
        """Test case for argumennt option 'include'"""
        testfile_include = "alias-calculator-commands.ipynb"
        command_opt_include = f"AUTOMATION_DURATION_RERUN=2 python3 automate_ipynb.py --include {testfile_include}" 
        output = gh.run(command_opt_include).split("\n")
        debug.trace(4, f"TestBatsppReport.test_arg_opt_include(); self={self}")
        count = sum(1 for _ in output if my_re.search(LOCALHOST_REGEX, _))
        testfile_include_true = any(testfile_include in _ for _ in output)
        assert (count == 1) and testfile_include_true

    def test_env_opt_select_nobatspp(self):
        """Tests environment option: SELECT_NOBATSPP"""
        debug.trace(4, f"TestBatsppReport.test_env_opt_select_nobatspp(); self={self}")
        output = gh.run("AUTOMATION_DURATION_RERUN=2 SELECT_NOBATSPP=1 python3 automate_ipynb.py")
        assert ("SELECT_NOBATSPP: True" in output)
        
    def test_env_opt_jupyter_password(self):
        """Tests environment option: JUPYTER_PASSWORD"""
        debug.trace(4, f"TestBatsppReport.test_env_opt_select_nobatspp(); self={self}")
        error_pass = "VWXRTNIKFA2EWDSFD4323EWDAONFRTJRGF"
        command = f"JUPYTER_PASSWORD={error_pass} AUTOMATION_DURATION_RERUN=2 python3 automate_ipynb.py"
        output = gh.run(command).split("\n")
        ## TODO: Close Jupyter (or driver) after assertion
        assertion_case = any("NoSuchElementError" in _ for _ in output)
        assert (assertion_case)

    def test_env_opt_use_firefox(self):
        """Tests environment option: USE_FIREFOX"""
        debug.trace(4, f"TestBatsppReport.test_env_opt_use_firefox(); self={self}")
        command = "USE_FIREFOX=False AUTOMATION_DURATION_RERUN=2 python3 automate_ipynb.py"
        output = gh.run(command).split("\n")
        exception_msg = "selenium.common.exceptions.WebDriverException: Message: disconnected: not connected to DevTools"
        assertion_case = exception_msg in output
        assert (assertion_case)

    ## OLD
    # #@pytest.mark.xfail
    # def test_include_option(self):
    #     """Tests include option from script"""
    #     debug.trace(4, f"TestBatsppReport.test_include_option(); self={self}")
        
    #     ## OLD: 
    #     # testfile_calculator = "alias-calculator-commands.ipynb"
    #     # self.temp = gh.create_temp_file(contents="")
    #     # # self.run_script(f"--include {testfile_calculator} 2>&1 {self.temp}")
    #     # output = self.run_script(f"--include {testfile_calculator}")
    #     # output_arr = output.split("\n") 
    #     # # output = gh.read_lines(self.temp)
    #     # is_include_working = False
    #     # for _ in output_arr:
    #     #     if testfile_calculator in _:
    #     #         is_include_working = True
    #     #         break
    #     # assert is_include_working
    #     TESTNAME_FOR_INCLUDE = "alias-calculator-commands.ipynb"
    #     REGEX_INCLUDE = r'alias-calculator-commands\.ipynb'
    #     output = self.run_script(f"--include {TESTNAME_FOR_INCLUDE}").split("\n")
    #     assert REGEX_INCLUDE in output

    # @pytest.mark.xfail
    # def test_first_option(self):
    #     """Tests first option from script"""
    #     debug.trace(4, f"TestBatsppReport.test_first_option(); self={self}")
    #     first_value = 2
    #     self.temp = gh.create_temp_file(contents="")
    #     # self.run_script(f"--first {first_value} > {self.temp}")
    #     # output = gh.read_lines(self.temp)
    #     output = self.run_script(f"--first {first_value}")
    #     output_arr = output.split("\n")
    #     urls = ["http://127.0.0.1:8888/tree/trace-python-commands.ipynb", "http://127.0.0.1:8888/tree/trace-line-words-commands.ipynb"]
    #     assertion_case = (output[0] == urls[0] and output[1] == urls[1] and output[2] == "")
    #     assert assertion_case

if __name__ == "__main__":
    unittest.main()