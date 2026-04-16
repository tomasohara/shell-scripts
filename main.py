#! /usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Simple app using mezcla main.py.
#
# note:
# - added mainly for debugging purposes
#

"""
TODO: what module does (brief)

Sample usage:
   echo $'TODO:task1\\nDONE:task2' | {script} --TODO-arg --
"""

# Standard modules
from typing import Optional

# Installed modules
## TODO: import numpy as np

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main, FILENAME
from mezcla.my_regex import my_re
from mezcla import system
## TODO:
## from mezcla import data_utils as du
## TODO2: streamline imports by exposing common functions, etc. in mezcla
##
## Optional:
## # Increase trace level for regex searching, etc. (e.g., from 6 to 7)
## my_re.TRACE_LEVEL = debug.QUITE_VERBOSE
debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

# Constants
TL = debug.TL
## TODO: Constants for switches omitting leading dashes (e.g., DEBUG_MODE = "debug-mode")
## Note: Run following in Emacs to interactively replace TODO_ARG with option label
##    M-: (query-replace-regexp "todo\\([-_]\\)arg" "arg\\1name")
## where M-: is the emacs keystroke short-cut for eval-expression.
##
## TODO: TODO_BOOL_OPT = "todo-bool-option"
## TODO: TODO_TEXT_OPT = "todo-text-option"

# Environment options
# Notes:
# - These are just intended for internal options, not for end users.
# - They also allow for enabling options in one place rather than four
#   when using main.Main (e.g., [Main member] initialization, run-time
#   value, and argument spec., along with string constant definition).
# WARNING: To minimize environment comflicts with other programs make the names
# longer such as two or more tokens (e.g., "FUBAR" => "FUBAR_LEVEL").
#
## TODO_FUBAR = system.getenv_bool(
##     "TODO_FUBAR", False,
##     description="TODO:Fouled Up Beyond All Recognition processing")

#-------------------------------------------------------------------------------

class Helper:
    """TODO: class for doing ..."""

    def __init__(self, _arg=None, **kwargs) -> None:
        """Initializer: TODO_arg desc"""
        debug.trace_expr(TL.VERBOSE, _arg, kwargs, prefix="in Helper.__init__: ")
        self._arg = _arg                # TODO: revise
        self.TODO: Optional[bool] = None
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def process(self, _arg) -> bool:
        """TODO: Process _ARG to do ..."""
        ## NOTE: print used for sake of unit test (see examples/tests/test_template.py)
        print("Error: TODO Implement me!")
        return False

#-------------------------------------------------------------------------------

def main() -> None:
    """Entry point"""
    debug.trace(TL.DETAILED, f"main(): script={system.real_path(__file__)}")

    # Parse command line options, show usage if --help given
    # TODO: manual_input=True; short_options=True
    # Note: Uses Main without subclassing, so some methods are stubs (e.g., run_main_step).
    main_app = Main(
        ## TODO2 (fix support): skip_input=True,
        ## TODO3 (add tip): manual_input=True,
        description=__doc__.format(script=gh.basename(__file__)),
        ## TODO: boolean_options=[(TODO_BOOL_OPT, "TODO desc1")],
        ## TODO: text_options=[(TODO_TEXT_OPT, "TODO desc2")],
        ## TODO: positional_arguments=[FILENAME, ALT_FILENAME], 
        ## NOTE: ALT_FILENAME usually requires skip_input and manual_input (e..g, to avoid - placeholder)
    )
    debug.reference_var(FILENAME)
    debug.assertion(main_app.parsed_args)
    ## TODO_opt1 = main_app.get_parsed_option(TODO_BOOL_OPT)

    helper = Helper()
    helper.process("TODO: some argument")
    
    ## TODO:
    ## ALT TODO:
    ## for line in main_app.read_entire_input().splitlines():
    ##     helper.process(TODO_fn(line))
    ## -or-
    ## helper.process( main_app.read_entire_input())

    ## Make sure no TODO_vars above (i.e., in namespace); TODO: delete check when stable
    debug.assertion(not any(my_re.search(r"^TODO_", m, my_re.IGNORECASE)
                            for m in dir(main_app)))
    return

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()
