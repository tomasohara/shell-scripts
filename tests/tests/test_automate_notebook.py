#! /usr/bin/env python3
#
# Tests for ../automate_notebook.py
#
# Notes:
# - Based on mezcla/tests/template.py (see mezcla-devel-clone/mezcla/tests/template.py).
# - Salvaged the CLI-level test ideas (--first/--include URL counting via TESTFILE_URL
#   regex) from the old tests/tests/test_automate_ipynb.py, which tested the now-archived
#   automate_ipynb.py (see tests/archive/). They require a live Jupyter server plus a
#   real Selenium browser driver, so they stay xfail here just like the original file.
#   (A separate explicit --help test isn't needed: TestWrapper.setUpClass already
#   invokes `--help` and asserts on it for every test module.)
# - The AutomateNotebook helper methods (return_ipynb_url_array, find_element,
#   click_element, do_it) don't need a live Jupyter server, so they are exercised
#   directly with a mocked Selenium driver.
#

"""Tests for automate_notebook module"""

# Standard modules
import time
from unittest.mock import MagicMock

# Installed modules
import nbformat
from nbclient import NotebookClient
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

# Note: used by test_18 to convert hello-world.batspp into a notebook for
# execution via nbclient (see BATSPP_KERNEL below)
try:
    import tests.batspp_to_jupyter as B2J_MODULE
except:
    try:
        import tests.tests.batspp_to_jupyter as B2J_MODULE
    except:
        system.print_exception_info("loading batspp_to_jupyter.py")
        B2J_MODULE = None

# Constants
LOCALHOST_REGEX = r"http://127\.0\.0\.1:8888/tree/tests/"
BATSPP_KERNEL = "bash"                   # matches `jupyter kernelspec list`

#------------------------------------------------------------------------

def _make_automate_notebook(monkeypatch, include="", first_n=0, verbose=""):
    """Creates THE_MODULE.AutomateNotebook with a mocked Selenium driver
    (n.b., avoids launching a real browser during unit tests)"""
    monkeypatch.setattr(THE_MODULE.webdriver, "Firefox", lambda **kwargs: MagicMock())
    monkeypatch.setattr(THE_MODULE.webdriver, "Chrome", lambda **kwargs: MagicMock())
    return THE_MODULE.AutomateNotebook(include, first_n, verbose)


def _last_stream_output_text_of(nb):
    """Returns the concatenated stdout text of the last code cell with stream
    output in notebook object NB"""
    for cell in reversed(nb.cells):
        texts = [o.get("text", "") for o in (cell.get("outputs") or [])
                if o.get("output_type") == "stream"]
        if texts:
            return "".join(texts).strip()
    return ""


def _last_stream_output_text(notebook_path):
    """Returns the concatenated stdout text of the last code cell with stream
    output in the notebook at NOTEBOOK_PATH (n.b., uses nbformat's read API
    rather than the file's OS-level modification time, as the latter doesn't
    actually prove the cell's shown output content changed)"""
    return _last_stream_output_text_of(nbformat.read(notebook_path, as_version=4))


class TestIt(TestWrapper):
    """Class for testcase definition"""
    # note: script_module used in argument parsing sanity check (e.g., --help)
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    @pytest.mark.xfail                   # requires a running (nbclassic) Jupyter server + browser driver
    def test_01_script_simple(self):
        """Simple integration test: running the script against a copy of
        dummy-test.ipynb should update the `date` shown in its last cell's
        output (n.b., proof the full round-trip of open/run-all/save
        actually happened via a real browser). Checks the cell's actual
        output text rather than the file's OS-level modification time,
        since the latter doesn't prove the shown content itself changed.
        Note: automates a throwaway copy rather than dummy-test.ipynb itself,
        as modifying repo-tracked files as a side effect of testing is bad
        practice. The copy has to live alongside the original under tests/
        (not some other temp dir) since AutomateNotebook only ever opens
        testfiles by basename against the local Jupyter instance rooted
        there (see the WARNING comment above TESTFILE_URL in
        automate_notebook.py)."""
        debug.trace(4, f"TestIt.test_01_script_simple(); self={self}")
        notebook = gh.resolve_path("dummy-test.ipynb", heuristic=True)
        notebook_copy = gh.form_path(gh.dirname(notebook), "_copy-dummy-test.ipynb")
        gh.copy_file(notebook, notebook_copy)
        try:
            orig_date_text = _last_stream_output_text(notebook_copy)
            self.run_script(data_file=notebook_copy)
            new_date_text = _last_stream_output_text(notebook_copy)
            self.do_assert(new_date_text and (new_date_text != orig_date_text),
                           f"Expected the date shown in {notebook_copy} to change "
                           f"(was {orig_date_text!r}, still {new_date_text!r})")
        finally:
            gh.delete_existing_file(notebook_copy)
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

    def test_12_automate_testfile_empty_list_no_crash(self):
        """Regression: automate_testfile([]) used to raise UnboundLocalError on 'driver'"""
        debug.trace(4, f"TestIt.test_12_automate_testfile_empty_list_no_crash(); self={self}")
        app = _make_automate_notebook(self.monkeypatch)
        app.automate_testfile([])
        self.do_assert(not app.driver.quit.called,
                       "driver.quit() should not be called when there are no testfiles")
        return

    def test_13_make_driver_headless_by_default(self):
        """Make sure the browser driver is created headless unless HEADLESS_WEBDRIVER=False"""
        debug.trace(4, f"TestIt.test_13_make_driver_headless_by_default(); self={self}")
        self.do_assert(THE_MODULE.HEADLESS_WEBDRIVER, "HEADLESS_WEBDRIVER should default to True")
        captured = {}
        self.monkeypatch.setattr(
            THE_MODULE.webdriver, "Firefox",
            lambda **kwargs: captured.setdefault("options", kwargs.get("options")))
        self.monkeypatch.setattr(THE_MODULE, "USE_FIREFOX", True)
        THE_MODULE.AutomateNotebook.make_driver()
        self.do_assert("-headless" in captured["options"].arguments,
                       f"Expected -headless argument, got {captured['options'].arguments}")
        return

    def test_14_make_driver_not_headless_when_disabled(self):
        """Make sure HEADLESS_WEBDRIVER=False omits the headless argument"""
        debug.trace(4, f"TestIt.test_14_make_driver_not_headless_when_disabled(); self={self}")
        captured = {}
        self.monkeypatch.setattr(
            THE_MODULE.webdriver, "Firefox",
            lambda **kwargs: captured.setdefault("options", kwargs.get("options")))
        self.monkeypatch.setattr(THE_MODULE, "USE_FIREFOX", True)
        self.monkeypatch.setattr(THE_MODULE, "HEADLESS_WEBDRIVER", False)
        THE_MODULE.AutomateNotebook.make_driver()
        self.do_assert("-headless" not in captured["options"].arguments,
                       f"Unexpected -headless argument: {captured['options'].arguments}")
        return

    def test_15_automate_testfile_uses_basename_for_foreign_paths(self):
        """Regression: an include path outside tests/ (e.g., a positional filename
        argument pointing elsewhere) should resolve via its basename, since testfiles
        are always served relative to TESTFILE_URL"""
        debug.trace(4, f"TestIt.test_15_automate_testfile_uses_basename_for_foreign_paths(); self={self}")
        app = _make_automate_notebook(self.monkeypatch)
        app.automate_testfile(["/some/other/dir/dummy-test.ipynb"])
        app.driver.get.assert_called_once_with(THE_MODULE.TESTFILE_URL + "dummy-test.ipynb")
        return

    def test_16_setup_uses_positional_filename_as_include(self):
        """Regression: a bare positional filename argument (not --include) used to be
        silently dropped, so the run fell back to scanning the cwd for notebooks.
        Note: uses /tmp/dummy-test.ipynb (rather than a wholly made-up name) since
        setup() now errors out on testfiles that can't be found in the repo by
        basename (see test_17 for that behavior)."""
        debug.trace(4, f"TestIt.test_16_setup_uses_positional_filename_as_include(); self={self}")
        app = THE_MODULE.RunScriptAutomateNotebook(
            runtime_args=["/tmp/dummy-test.ipynb"], skip_input=False, manual_input=True,
            auto_help=True, text_options=[(THE_MODULE.OPT_INCLUDE_TESTFILE, "include")],
            int_options=[(THE_MODULE.OPT_FIRST_N_TESTFILE, "first")],
            boolean_options=[(THE_MODULE.OPT_VERBOSE, "verbose")])
        app.setup()
        self.do_assert(app.opt_include_testfile == "/tmp/dummy-test.ipynb",
                       f"Unexpected opt_include_testfile: {app.opt_include_testfile}")
        return

    def test_17_setup_errors_on_testfile_not_in_repo(self):
        """Make sure setup() issues a fatal error for a testfile not found in the repo"""
        debug.trace(4, f"TestIt.test_17_setup_errors_on_testfile_not_in_repo(); self={self}")
        app = THE_MODULE.RunScriptAutomateNotebook(
            runtime_args=["/tmp/totally-bogus-notebook.ipynb"], skip_input=False, manual_input=True,
            auto_help=True, text_options=[(THE_MODULE.OPT_INCLUDE_TESTFILE, "include")],
            int_options=[(THE_MODULE.OPT_FIRST_N_TESTFILE, "first")],
            boolean_options=[(THE_MODULE.OPT_VERBOSE, "verbose")])
        with pytest.raises(SystemExit):
            app.setup()
        return

    def test_18_hello_world_batspp_epoch_seconds_updates(self):
        """Uses the nbformat/nbclient notebook execution API (headless: no
        browser or live Jupyter server needed, unlike test_01) to confirm the
        'Seconds since epoch' line at the end of hello-world.batspp reflects
        a genuinely live command rather than a static value: converts the
        batspp file to a notebook via batspp_to_jupyter.py's own conversion
        API, executes it twice a beat apart, and checks the epoch value
        increased."""
        debug.trace(4, f"TestIt.test_18_hello_world_batspp_epoch_seconds_updates(); self={self}")
        batspp_file = gh.resolve_path("hello-world.batspp", heuristic=True)
        temp_dir = self.get_temp_dir()
        self.monkeypatch.chdir(temp_dir)
        converter = B2J_MODULE.BatsppToJupyter(batspp_file, "", False, False, False)
        converter.process_nb()
        notebook_path = gh.form_path(temp_dir, "hello-world.ipynb")
        self.do_assert(system.file_exists(notebook_path),
                       f"Expected {notebook_path} to be generated by BatsppToJupyter")
        nb = nbformat.read(notebook_path, as_version=4)

        def epoch_seconds():
            match = my_re.search(r"Seconds since epoch:\s*(\d+)", _last_stream_output_text_of(nb))
            return int(match.group(1)) if match else None

        NotebookClient(nb, kernel_name=BATSPP_KERNEL, timeout=30).execute()
        first_epoch = epoch_seconds()
        self.do_assert(first_epoch is not None,
                       "Expected a 'Seconds since epoch' line in hello-world.batspp output")

        time.sleep(1.1)                  # date +%s has 1-second granularity
        NotebookClient(nb, kernel_name=BATSPP_KERNEL, timeout=30).execute()
        second_epoch = epoch_seconds()

        self.do_assert(second_epoch > first_epoch,
                       f"Expected epoch seconds to increase across runs (was {first_epoch}, now {second_epoch})")
        return


#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    invoke_tests(__file__)
