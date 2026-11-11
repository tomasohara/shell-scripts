#! /usr/bin/env python3
#
# Provides a minimalist, frameless PyQt6 window with a single button.
# The window takes a string via command-line argument. When clicked, 
# the text is copied to the system clipboard and the application stays open 
# to allow multiple clicks. It is intended for quick, temporary copy-paste 
# utility tasks (similar in spirit to xmessage).
#
# Note:
# - For window flags, see https://doc.qt.io/qt-6/qt.html#WindowType-enum
# 
# Change facilitated by Antigravity using model Gemini 3.1 Pro (Low).
#
## UPDATE 2026-10-1: adds ability to run command
## UPDATE 2026-09-23: reworks Qt window flags to make optional

"""
Creates minimal window with button to copy text to clipboard

Sample usage:
   ./clipboard_button.py "2026-09-21"
"""

# Standard modules
import sys
import shlex
from typing import Optional

# Installed modules
# pylint: disable=no-name-in-module
from PyQt6.QtWidgets import QApplication, QPushButton
from PyQt6.QtCore import Qt
# pylint: enable=no-name-in-module

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system

# Constants
TL = debug.TL
TEXT_ARG = "text"

WINDOW_FLAGS = system.getenv_value(
    "WINDOW_FLAGS", None,
    desc="Qt Window flags to apply")
WINDOW_FRAMELESS = system.getenv_bool(
    "WINDOW_FRAMELESS", False,
    desc="Apply Qt.WindowType.FramelessWindowHint")
WINDOW_TOOL = system.getenv_bool(
    "WINDOW_TOOL", False,
    desc="Apply Qt.WindowType.Tool")
BASH_SNIPPET = system.getenv_bool(
    "BASH_SNIPPET", False,
    desc="Evaluate text as Bash snippet to derive result")
BASH_INTERACTIVE = system.getenv_bool(
    "BASH_INTERACTIVE", False,
    desc="Run Bash snippets interactively to enable aliases")
UPDATE_BUTTON = system.getenv_bool(
    "UPDATE_BUTTON", False,
    desc="Update button to Bash snippet output")


def get_window_flags(value: Optional[str]) -> Qt.WindowType:
    """Convert a numeric or pipe-delimited Qt window-flag setting to flags."""
    flags = Qt.WindowType.Widget
    if value:
        try:
            flags = Qt.WindowType(int(value, base=0))
        except ValueError:
            for name in value.split("|"):
                name = name.strip().removeprefix("Qt.WindowType.")
                try:
                    flags |= getattr(Qt.WindowType, name)
                except AttributeError as err:
                    raise ValueError(
                        f"Invalid WINDOW_FLAGS value: {value!r}") from err
    return flags


class ClipboardButton(QPushButton): # pylint: disable=too-few-public-methods
    """UI class for the minimalist clipboard button"""

    def __init__(self, text: str):
        """Initialize the minimalist UI button"""
        debug.trace(TL.VERBOSE, f"ClipboardButton.__init__({text}): self={self}")
        super().__init__(text)
        self._text = text
        self._snippet = text

        # Apply minimalist frameless window hint similar to xmessage
        ## OLD: self.setWindowFlags(Qt.WindowType.FramelessWindowHint | Qt.WindowType.Tool)
        flags = get_window_flags(WINDOW_FLAGS)
        if WINDOW_FRAMELESS:
            flags |= Qt.WindowType.FramelessWindowHint
        if WINDOW_TOOL:
            flags |= Qt.WindowType.Tool
        if flags:
            debug.trace_expr(4, flags)
            self.setWindowFlags(flags)
        self.clicked.connect(self.on_click)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

        # Simulate initial click to derive text for button
        if BASH_SNIPPET and UPDATE_BUTTON:
            self.on_click()

    def on_click(self) -> None:
        """Copies text to the clipboard upon button click"""
        debug.trace(6, "ClipboardButton.on_click()")
        ## OLD:
        ## debug.trace(TL.USUAL, f"Button clicked, copying text: {self._text}")
        ## QApplication.clipboard().setText(self._text)
        ## debug.assertion(QApplication.clipboard().text() == self._text)
        action = "copying" if not BASH_SNIPPET else "evaluating"
        debug.trace(TL.USUAL, f"Button clicked, {action} text: {self._snippet}")
        text = self._snippet
        if BASH_SNIPPET:
            log = gh.get_temp_file()
            bash_options = "-ic" if BASH_INTERACTIVE else "-c"
            command = (
                f"BATCH_MODE=1 CONSOLE_TRACING=0 bash {bash_options} "
                f"{shlex.quote(self._snippet)} 2> {shlex.quote(log)}"
            )
            text = gh.run(command)
        QApplication.clipboard().setText(text)
        if UPDATE_BUTTON:
            self._text = gh.elide(text)
            self.setText(self._text)
        debug.trace_object(6, self, label=f"{self.__class__.__name__} instance")

class ClipboardButtonApp(Main):
    """Script input processing class for minimalist clipboard button"""
    text_arg: str = ""
    button: Optional[ClipboardButton] = None

    def setup(self) -> None:
        """Check results of command line processing"""
        debug.trace(TL.VERBOSE, f"ClipboardButtonApp.setup(): self={self}")

        val = self.get_parsed_argument(TEXT_ARG, self.text_arg)
        if val is not None:
            self.text_arg = str(val)

    def run_main_step(self) -> None:
        """Main processing step"""
        debug.trace(TL.DETAILED, f"ClipboardButtonApp.run_main_step(): self={self}")

        app = QApplication.instance()
        if app is None:
            app = QApplication(sys.argv)

        self.button = ClipboardButton(self.text_arg)
        self.button.show()

        # Start event loop
        app.exec()


#-------------------------------------------------------------------------------

def main() -> None:
    """Entry point"""
    debug.trace(TL.DETAILED, f"main(): script={system.real_path(__file__)}")

    app = ClipboardButtonApp(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        positional_arguments=[TEXT_ARG]
    )
    app.run()


#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()
