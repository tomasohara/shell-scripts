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

# Constants
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
        assert(my_re.search(r"automate", result))

    def test_env_opt_select_nobatspp(self):
        """Tests environment option: SELECT_NOBATSPP"""
        debug.trace(4, f"TestBatsppReport.test_env_opt_select_nobatspp(); self={self}")

    @pytest.mark.xfail
    def test_include_option(self):
        """Tests include option from script"""
        debug.trace(4, f"TestBatsppReport.test_include_option(); self={self}")
        testfile_calculator = "alias-calculator-commands"
        self.temp = gh.create_temp_file(contents="")
        self.run_script(f"--include {testfile_calculator} > {self.temp}")
        output = gh.read_lines(self.temp)
        assert testfile_calculator in output

    @pytest.mark.xfail
    def test_first_option(self):
        """Tests first option from script"""
        debug.trace(4, f"TestBatsppReport.test_first_option(); self={self}")
        first_value = 2
        self.temp = gh.create_temp_file(contents="")
        self.run_script(f"--first {first_value} > {self.temp}")
        output = gh.read_lines(self.temp)
        urls = ["http://127.0.0.1:8888/tree/trace-python-commands.ipynb", "http://127.0.0.1:8888/tree/trace-line-words-commands.ipynb"]
        assertion_case = (output[0] == urls[0] and output[1] == urls[1] and output[2] == "")
        assert assertion_case


if __name__ == "__main__":
    unittest.main()