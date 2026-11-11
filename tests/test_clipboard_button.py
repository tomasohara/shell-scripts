#! /usr/bin/env python3

"""Tests for clipboard_button module

Change facilitated by Antigravity using model Gemini 3.1 Pro (Low).
"""

# Standard modules
import sys
import os
from unittest import mock

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

# Force the local repository root to be at the front of sys.path 
# so that we don't accidentally import the globally installed Mezcla-tpo.
_repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
if _repo_root in sys.path:
    sys.path.remove(_repo_root)
sys.path.insert(0, _repo_root)

# If mezcla was already imported from the global install, remove it
if "mezcla" in sys.modules:
    if not sys.modules["mezcla"].__file__.startswith(_repo_root):
        del sys.modules["mezcla"]
        # Also remove submodules
        for k in list(sys.modules.keys()):
            if k.startswith("mezcla."):
                del sys.modules[k]

# Installed modules
# pylint: disable=no-name-in-module
from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import QApplication
# pylint: enable=no-name-in-module

# Local modules
from mezcla import debug
from mezcla import system
from mezcla.unittest_wrapper import TestWrapper, invoke_tests

THE_MODULE = None
try:
    ## OLD: import mezcla.clipboard_button as THE_MODULE
    import clipboard_button as THE_MODULE
except Exception: # pylint: disable=broad-except
    system.print_exception_info("clipboard_button import")

class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    qapp = None

    @classmethod
    def setUpClass(cls) -> None:
        """Create and retain the Qt application for all widget tests."""
        super().setUpClass()
        cls.qapp = QApplication.instance() or QApplication(sys.argv)

    def test_01_gui(self) -> None:
        """Tests the GUI button creation and logic"""
        debug.trace(4, f"TestIt.test_01_gui(); self={self}")

        # Initialize the UI directly
        button = THE_MODULE.ClipboardButton("test_12345")

        # Fake click
        button.click()

        self.do_assert(
            self.qapp.clipboard().text() == "test_12345",
            "Clipboard not updated")

    def test_02_window_flags(self) -> None:
        """Tests named and numeric window-flag parsing."""
        named_flags = THE_MODULE.get_window_flags("Tool|FramelessWindowHint")
        numeric_flags = THE_MODULE.get_window_flags(
            str(Qt.WindowType.Tool.value))
        self.do_assert(
            named_flags & Qt.WindowType.Tool,
            "Named Tool flag not applied")
        self.do_assert(
            named_flags & Qt.WindowType.FramelessWindowHint,
            "Named FramelessWindowHint flag not applied")
        self.do_assert(
            numeric_flags == Qt.WindowType.Tool,
            "Numeric window flag not parsed")

    def test_03_bash_snippet_quoting(self) -> None:
        """Tests non-interactive Bash snippets are passed as one argument."""
        snippet = 'printf "%s" "two words"'
        with mock.patch.object(THE_MODULE, "BASH_SNIPPET", True), \
             mock.patch.object(THE_MODULE.gh, "get_temp_file",
                               return_value="/tmp/clipboard-button.log"), \
             mock.patch.object(THE_MODULE.gh, "run",
                               return_value="two words") as run:
            button = THE_MODULE.ClipboardButton(snippet)
            button.click()

        self.do_assert(
            run.call_args.args[0] == (
                "BATCH_MODE=1 CONSOLE_TRACING=0 bash -c "
                "'printf \"%s\" \"two words\"' 2> /tmp/clipboard-button.log"),
            "Bash snippet was not shell-quoted")
        self.do_assert(
            self.qapp.clipboard().text() == "two words",
            "Bash snippet output was not copied")

    def test_04_interactive_bash_snippet(self) -> None:
        """Tests the opt-in interactive Bash mode."""
        with mock.patch.object(THE_MODULE, "BASH_SNIPPET", True), \
             mock.patch.object(THE_MODULE, "BASH_INTERACTIVE", True), \
             mock.patch.object(THE_MODULE.gh, "get_temp_file",
                               return_value="/tmp/clipboard-button.log"), \
             mock.patch.object(THE_MODULE.gh, "run",
                               return_value="result") as run:
            button = THE_MODULE.ClipboardButton("alias")
            button.click()

        self.do_assert(
            run.call_args.args[0] == (
                "BATCH_MODE=1 CONSOLE_TRACING=0 bash -ic alias "
                "2> /tmp/clipboard-button.log"),
            "Interactive Bash option was not enabled")

if __name__ == '__main__':
    debug.trace_current_context()
    invoke_tests(__file__)
