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
import re

# Installed Packages
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.alert import Alert

# Local Modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla.my_regex import my_re

# Script Import

# Constants
# TODO2: get OUTPUT_DIR from THE_MODULE.OUTPUT_DIR
OUTPUT_DIR = system.getenv_text("OUTPUT_DIR", ".",
                                "Directory for output files such as .batspp test specs")
# note: script should either run in ./tests dir or define TEST_DIR
TEST_DIR = system.real_path(gh.dirname(__file__ or "."))
debug.assertion(TEST_DIR.endswith("tests"))

class TestAutomateIPYNB(unittest.TestCase):
    """Class for testcase definition"""
    script = gh.resolve_path("automate_batspp_indev.py")
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
        assert(my_re.search(r"Test.*Automate.*Bash", result))


if __name__ == "__main__":
    unittest.main()

     
