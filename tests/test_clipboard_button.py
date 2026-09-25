#! /usr/bin/env python3

"""Tests for clipboard_button module

Change facilitated by Antigravity using model Gemini 3.1 Pro (Low).
"""

# Standard modules
import sys
import os

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
from PyQt5.QtWidgets import QApplication
# pylint: enable=no-name-in-module

# Local modules
from mezcla import debug
from mezcla import system
from mezcla.unittest_wrapper import TestWrapper, invoke_tests

THE_MODULE = None
try:
    import mezcla.clipboard_button as THE_MODULE
except Exception: # pylint: disable=broad-except
    system.print_exception_info("clipboard_button import")

class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    def test_01_gui(self) -> None:
        """Tests the GUI button creation and logic"""
        debug.trace(4, f"TestIt.test_01_gui(); self={self}")

        qapp = QApplication.instance()
        if not qapp:
            qapp = QApplication(sys.argv)

        # Initialize the UI directly
        button = THE_MODULE.ClipboardButton("test_12345")

        # Fake click
        button.click()

        self.do_assert(qapp.clipboard().text() == "test_12345", "Clipboard not updated")

if __name__ == '__main__':
    debug.trace_current_context()
    invoke_tests(__file__)
