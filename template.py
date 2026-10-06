#! /usr/bin/env python3
##
## Main template for mezcla scripts. This version gets mirrored in shell-scripts repo,
## which is done for historical reasons (rather than using ./examples version).
## (TODO: delete this comment during customization)
##..............................................................................
# TODO: # -*- coding: utf-8 -*-
## TODO: handle case when env installed elsewhere (e.g., maldito mac)
## #! env python
# 
# TODO what the script does (detailed)
#
## TODO: see example/template.py for simpler version suitable for cut-n-paste from online examples
##
## NOTE: The TODO tips include optional priority (see Script init at end). In general,
##    TODOn ...: with lower values having higher priority
## Comments using '##' are meant to guide initial customization
##    NOTE: Uses scare caps in throwaway comments. 
#

"""
TODO: what module does (brief)

Sample usage:
   echo $'TODO:task1\\nDONE:task2' | {script} --TODO-arg --
"""

# Standard modules
from typing import Any, Optional

# Installed modules
## TODO: import numpy as np

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
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
#
## TODO: Constants for switches, omitting leading dashes (e.g., DEBUG_MODE = "debug-mode")
## Note: Run following in Emacs to interactively replace TODO_ARG with option label
##    M-: (query-replace-regexp "todo\\([-_]\\)arg" "arg\\1name")
## where M-: is the emacs keystroke short-cut for eval-expression.
TODO_ARG = "TODO-arg"
## TEXT_ARG = "text-arg"
## ALT_FILENAME = "alt_filename"

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

    def __init__(self, _arg: Any = None, **kwargs) -> None:
        """Initializer: TODO_arg desc"""
        debug.trace_expr(TL.VERBOSE, _arg, kwargs, prefix="in Helper.__init__: ")
        self._arg = _arg                # TODO: revise
        self.TODO: Optional[bool] = None
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def process(self, _arg: Any) -> bool:
        """TODO: Process _ARG to do ..."""
        ## NOTE: print used for sake of unit test (see tests/test_template.py)
        try:
            print("Error: TODO Implement me!")
        except:
            system.print_exception_info("process")
        return False

    
class Script(Main):
    """Script input processing class"""
    # TODO: -or-: """Adhoc script class (e.g., no I/O loop, just run calls)"""
    ## TODO: class-level member variables for arguments (avoids need for class constructor)
    todo_arg: Optional[bool] = False
    ## text_arg = ""
    helper = None

    # TODO: add class constructor if needed for non-standard initialization
    ## WARNING: For Script classes involving complex logic, it is best to use helper classes,
    ## as done in show_bert_representation.py.
    ## NOTE: Such class decomposition is also beneficial for unit tests.
    #
    ## def __init__(self, *args, **kwargs):
    ##     debug.trace_expr(TL.VERBOSE, self, args, kwargs, delim="\n\t", prefix="in {self.__class__.__name__}.__init__({args}, {kwargs})")
    ##     super().__init__(*args, **kwargs)

    def setup(self) -> None:
        """Check results of command line processing"""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        ## TODO: extract argument values
        ## TODO3: mypy now flags this assignment since Main.get_parsed_option returns
        ## main.OptArgValue (Optional[Union[str, int, float, bool, List[str]]]), which
        ## is broader than this class's todo_arg: Optional[bool]. This was previously
        ## masked by Optional[Any]. Boolean options always yield bool from argparse,
        ## so this is safe at runtime; restructuring (e.g., a bool-specific accessor)
        ## would be needed to satisfy mypy without a cast.
        self.todo_arg = self.get_parsed_option(TODO_ARG, self.todo_arg)
        self.helper = Helper()
        ## TODO:
        ## self.text_arg = self.get_parsed_option(TEXT_ARG, self.text_arg)
        ## self.alt_filename = self.get_parsed_argument(ALT_FILENAME)
        ## OLD:
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
        ## TEST: debug.trace_object(5, self, label=f"{self.__init__.__qualname__.split('.')[0]} instance")

    def process_line(self, line: str) -> None:
        """Processes current line from input"""
        debug.trace_fmtd(TL.QUITE_DETAILED, "Script.process_line({l})", l=line)
        self.helper.process(line)

    ## TODO: if no input prococessed, customize run_main_step instead
    ## and specify skip_input below. (Use skip_input=False for filename support.)
    ##
    ## def run_main_step(self) -> None:
    ##     """Main processing step (n.b., assumes self.manual_input)"""
    ##     debug.trace(5, f"Script.run_main_step(): self={self}")
    ##     ...
    ##     ## TODO: data = self.read_entire_input()
    #@     ...
    ##

    ## TODO:
    ## def wrap_up(self) -> None:
    ##     """Do final processing"""
    ##     debug.trace(6, f"Script.wrap_up(); self={self}")
    ##     # ...

#-------------------------------------------------------------------------------

def main() -> None:
    """Entry point"""
    debug.trace(TL.DETAILED, f"main(): script={system.real_path(__file__)}")

    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        # Note: if not manual_input, line-by-line processing is done via process_line;
        # otherwise, run_main_step is used. Use skip_input to disable filename argument.
        skip_input=False,
        manual_input=False,
        ## TODO (specify auto_help such as when manual_input set):
        ## # Note: shows brief usage if no arguments given
        ## auto_help=True,
        ## -or-: # Disable inference of --help argument
        ## auto_help=False,
        ## TODO: specify options and (required) arguments
        boolean_options=[(TODO_ARG, "TODO-desc--currently greps for TODO")],
        ## TODO (refine based on following tips):
        ## NOTE: FILENAME is default argument unless skip_input
        ## positional_arguments=[FILENAME, ALT_FILENAME], 
        ## text_options=[(TEXT_ARG, "TODO-desc")],
        ##
        ## TODO4 (use one or more of the arcane options)
        ## short_options=True,
        ## paragraph_mode=True,
        ## NOTE: See Main.__init__ in main.py for others.
        ## 
        ## NOTE: Following added for indentation--float options not common (TODO: remove?)
        float_options=None)
    app.run()

    ## Make sure no TODO_vars above (i.e., in namespace); TODO: delete check when stable
    debug.assertion(not any(my_re.search(r"^TODO_", m, my_re.IGNORECASE)
                            for m in dir(app)))
    return

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__, assert_level=TL.DETAILED)
    main()
