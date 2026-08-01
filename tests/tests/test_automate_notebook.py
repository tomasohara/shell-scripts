#! /usr/bin/env python3
#
# Tests for ../automate_notebook.py
#
# Notes:
# - Based on mezcla/tests/template.py (see mezcla-devel-clone/mezcla/tests/template.py).
# - Salvaged the CLI-level test ideas (help check, --first/--include URL counting via
#   TESTFILE_URL regex) from the old tests/tests/test_automate_ipynb.py, which tested
#   the now-archived automate_ipynb.py (see tests/archive/). The --first/--include
#   variants require a live Jupyter server plus a real Selenium browser driver, so
#   they stay xfail here just like they were in the original file.
# - The AutomateNotebook helper methods (return_ipynb_url_array, find_element,
#   click_element, do_it) don't need a live Jupyter server, so they are exercised
#   directly with a mocked Selenium driver.
#

"""Tests for automate_notebook module"""

# Standard modules
from unittest.mock import MagicMock

# Installed modules
import pytest

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system
from mezcla.unittest_wrapper import TestWrapper, invoke_tests

# Note: Two references are used for the module to be tested:
#    THE_MODULE:               module object (e.g., <module 'tests.automate_notebook' ...>)
#    TestIt.script_module:     dotted module path (e.g., "tests.automate_notebook")
try:
    import tests.automate_notebook as THE_MODULE
except:
    try:
        import tests.tests.automate_notebook as THE_MODULE
    except:
        system.print_exception_info("loading automate_notebook.py")
        THE_MODULE = None

# Constants
LOCALHOST_REGEX = r"http://127\.0\.0\.1:8888/tree/tests/"

#------------------------------------------------------------------------

def _make_automate_notebook(monkeypatch, include="", first_n=0, verbose=""):
    """Creates THE_MODULE.AutomateNotebook with a mocked Selenium driver
    (n.b., avoids launching a real browser during unit tests)"""
    monkeypatch.setattr(THE_MODULE.webdriver, "Firefox", lambda: MagicMock())
    monkeypatch.setattr(THE_MODULE.webdriver, "Chrome", lambda: MagicMock())
    return THE_MODULE.AutomateNotebook(include, first_n, verbose)


class TestIt(TestWrapper):
    """Class for testcase definition"""
    # note: script_module used in argument parsing sanity check (e.g., --help)
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    def test_01_script_help(self):
        """Make sure script usage shown with --help"""
        debug.trace(4, f"TestIt.test_01_script_help(); self={self}")
        output = self.run_script("--help")
        self.do_assert(my_re.search(r"Automates.*Jupyter.*Selenium", output),
                       "Usage statement not shown via --help")
        return

    @pytest.mark.xfail                   # requires a running Jupyter server + browser driver
    def test_02_arg_opt_first(self):
        """Test case for argument option 'first'"""
        debug.trace(4, f"TestIt.test_02_arg_opt_first(); self={self}")
        output = self.run_script(options="--first 3",
                                 env_options="AUTOMATION_DURATION_RERUN=1")
        count = sum(1 for line in output.split("\n") if my_re.search(LOCALHOST_REGEX, line))
        self.do_assert(count == 3, "Expected 3 testfile URLs from --first 3")
        return

    @pytest.mark.xfail                   # requires a running Jupyter server + browser driver
    def test_03_arg_opt_include(self):
        """Test case for argument option 'include'"""
        debug.trace(4, f"TestIt.test_03_arg_opt_include(); self={self}")
        testfile_include = "alias-calculator-commands.ipynb"
        output = self.run_script(options=f"--include {testfile_include}",
                                 env_options="AUTOMATION_DURATION_RERUN=1")
        count = sum(1 for line in output.split("\n") if my_re.search(LOCALHOST_REGEX, line))
        self.do_assert((count == 1) and (testfile_include in output),
                       "Expected exactly 1 testfile URL matching --include argument")
        return

    #.........................................................................
    # Unit-level tests for AutomateNotebook helper methods (no live server needed)

    def test_04_return_ipynb_url_array_excludes_nobatspp_by_default(self):
        """Make sure return_ipynb_url_array() skips NOBATSPP files unless SELECT_NOBATSPP set"""
        debug.trace(4, f"TestIt.test_04_return_ipynb_url_array_excludes_nobatspp_by_default(); self={self}")
        temp_dir = self.get_temp_dir()
        system.write_file(gh.form_path(temp_dir, "alpha.ipynb"), "{}")
        system.write_file(gh.form_path(temp_dir, "NOBATSPP-beta.ipynb"), "{}")
        system.write_file(gh.form_path(temp_dir, "not-a-notebook.txt"), "x")
        self.monkeypatch.chdir(temp_dir)
        app = _make_automate_notebook(self.monkeypatch)
        urls = app.return_ipynb_url_array()
        self.do_assert(urls == [THE_MODULE.TESTFILE_URL + "alpha.ipynb"],
                       f"Unexpected URL list: {urls}")
        return

    def test_05_return_ipynb_url_array_select_nobatspp(self):
        """Make sure SELECT_NOBATSPP=True includes NOBATSPP files"""
        debug.trace(4, f"TestIt.test_05_return_ipynb_url_array_select_nobatspp(); self={self}")
        temp_dir = self.get_temp_dir()
        system.write_file(gh.form_path(temp_dir, "alpha.ipynb"), "{}")
        system.write_file(gh.form_path(temp_dir, "NOBATSPP-beta.ipynb"), "{}")
        self.monkeypatch.chdir(temp_dir)
        self.monkeypatch.setattr(THE_MODULE, "SELECT_NOBATSPP", True)
        app = _make_automate_notebook(self.monkeypatch)
        urls = app.return_ipynb_url_array()
        expected = [THE_MODULE.TESTFILE_URL + f for f in sorted(["alpha.ipynb", "NOBATSPP-beta.ipynb"])]
        self.do_assert(urls == expected, f"Unexpected URL list: {urls}")
        return

    def test_06_return_ipynb_url_array_first_n(self):
        """Make sure the 'first' option truncates the sorted testfile list"""
        debug.trace(4, f"TestIt.test_06_return_ipynb_url_array_first_n(); self={self}")
        temp_dir = self.get_temp_dir()
        for name in ["a.ipynb", "b.ipynb", "c.ipynb"]:
            system.write_file(gh.form_path(temp_dir, name), "{}")
        self.monkeypatch.chdir(temp_dir)
        app = _make_automate_notebook(self.monkeypatch, first_n=2)
        urls = app.return_ipynb_url_array()
        expected = [THE_MODULE.TESTFILE_URL + "a.ipynb", THE_MODULE.TESTFILE_URL + "b.ipynb"]
        self.do_assert(urls == expected, f"Unexpected URL list: {urls}")
        return

    def test_07_return_ipynb_url_array_include(self):
        """Make sure the 'include' option overrides the directory listing"""
        debug.trace(4, f"TestIt.test_07_return_ipynb_url_array_include(); self={self}")
        temp_dir = self.get_temp_dir()
        for name in ["a.ipynb", "b.ipynb"]:
            system.write_file(gh.form_path(temp_dir, name), "{}")
        self.monkeypatch.chdir(temp_dir)
        app = _make_automate_notebook(self.monkeypatch, include="b.ipynb")
        urls = app.return_ipynb_url_array()
        self.do_assert(urls == [THE_MODULE.TESTFILE_URL + "b.ipynb"], f"Unexpected URL list: {urls}")
        return

    def test_08_find_element_handles_exception(self):
        """Make sure find_element() returns None instead of raising when element missing"""
        debug.trace(4, f"TestIt.test_08_find_element_handles_exception(); self={self}")
        app = _make_automate_notebook(self.monkeypatch)
        app.driver.find_element.side_effect = Exception("no such element")
        result = app.find_element(THE_MODULE.By.ID, "missing-id")
        self.do_assert(result is None, "find_element should return None on failure")
        return

    def test_09_click_element_handles_exception(self):
        """Make sure click_element() returns None instead of raising when element missing"""
        debug.trace(4, f"TestIt.test_09_click_element_handles_exception(); self={self}")
        app = _make_automate_notebook(self.monkeypatch)
        app.driver.find_element.side_effect = Exception("no such element")
        result = app.click_element(THE_MODULE.By.ID, "missing-id", delay=0)
        self.do_assert(result is None, "click_element should return None on failure")
        return

    def test_10_do_it_uses_include_file_when_set(self):
        """Make sure do_it() automates just the include file when one is given"""
        debug.trace(4, f"TestIt.test_10_do_it_uses_include_file_when_set(); self={self}")
        app = _make_automate_notebook(self.monkeypatch, include="only-this.ipynb")
        captured = {}
        self.monkeypatch.setattr(app, "automate_testfile", lambda files: captured.setdefault("files", files))
        app.do_it()
        self.do_assert(captured.get("files") == ["only-this.ipynb"],
                       f"Unexpected files passed to automate_testfile: {captured}")
        return

    def test_11_do_it_uses_directory_listing_when_no_include(self):
        """Make sure do_it() falls back to the directory listing when no include file is given"""
        debug.trace(4, f"TestIt.test_11_do_it_uses_directory_listing_when_no_include(); self={self}")
        temp_dir = self.get_temp_dir()
        system.write_file(gh.form_path(temp_dir, "solo.ipynb"), "{}")
        self.monkeypatch.chdir(temp_dir)
        app = _make_automate_notebook(self.monkeypatch)
        captured = {}
        self.monkeypatch.setattr(app, "automate_testfile", lambda files: captured.setdefault("files", files))
        app.do_it()
        self.do_assert(captured.get("files") == [THE_MODULE.TESTFILE_URL + "solo.ipynb"],
                       f"Unexpected files passed to automate_testfile: {captured}")
        return


#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    invoke_tests(__file__)
