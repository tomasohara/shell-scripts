#! /usr/bin/env python
# TODO: # -*- coding: utf-8 -*-
## TODO: handle case when env installed elsewhere (e.g., maldito mac)
## #! env python
# 
# TODO what the script does (detailed)
#
## TODO: see example/template.py for simpler version suitable for cut-n-paste from online examples
#

"""
TODO: what module does (brief)

Sample usage:
   echo $'TODO:task1\\nDONE:task2' | {script} --TODO-arg --
"""

# Standard modules
## TODO: from collections import defaultdict

# Installed modules
## TODO: import numpy

# Local modules
# TODO: def mezcla_import(name): ... components = eval(name).split(); ... import nameN-1.nameN as nameN
from mezcla import debug
from mezcla.main import Main
from mezcla import system
from mezcla.my_regex import my_re
## TODO:
## from mezcla import glue_helpers as gh
## from mezcla import data_utils as du
##
## Optional:
## # Increase trace level for regex searching, etc. (e.g., from 6 to 7)
## my_re.TRACE_LEVEL = debug.QUITE_VERBOSE
debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

## TODO: Constants for switches omitting leading dashes (e.g., DEBUG_MODE = "debug-mode")
## Note: Run following in Emacs to interactively replace TODO_ARG with option label
##    M-: (query-replace-regexp "todo\\([-_]\\)arg" "arg\\1name")
## where M-: is the emacs keystroke short-cut for eval-expression.
TODO_ARG = "TODO-arg"
## TEXT_ARG = "text-arg"
## ALT_FILENAME = "alt_filename"

# Constants
TL = debug.TL

# Environment options
# Note: These are just intended for internal options, not for end users.
# It also allows for enabling options in one place rather than four
# (e.g., [Main member] initialization, run-time value, and argument spec., along
# with string constant definition).
#
TODO_FUBAR = system.getenv_bool("TODO_FUBAR", False,
                                description="TODO:Fouled Up Beyond All Recognition processing")


class Script(Main):
    """Input processing class"""
    # TODO: -or-: """Adhoc script class (e.g., no I/O loop, just run calls)"""
    ## TODO: class-level member variables for arguments (avoids need for class constructor)
    todo_arg = False
    ## text_arg = ""

    # TODO: add class constructor if needed for non-standard initialization
    ## WARNING: For Script classes involving complex logic, it is best to use helper classes,
    ## as done in show_bert_representation.py.
    ## NOTE: Such class decomposition is also beneficial for unit tests.
    #
    ## def __init__(self, *args, **kwargs):
    ##     debug.trace_fmtd(TL.VERBOSE, "Script.__init__({a}): keywords={kw}; self={s}",
    ##                      a=",".join(args), kw=kwargs, s=self)
    ##     super().__init__(*args, **kwargs)
    
    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(TL.VERBOSE, "Script.setup(): self={s}", s=self)
        ## TODO: extract argument values
        self.todo_arg = self.get_parsed_option(TODO_ARG, self.todo_arg)
        ## TODO:
        ## self.text_arg = self.get_parsed_option(TEXT_ARG, self.text_arg)
        ## self.alt_filename = self.get_parsed_argument(ALT_FILENAME)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def process_line(self, line):
        """Processes current line from input"""
        debug.trace_fmtd(TL.QUITE_DETAILED, "Script.process_line({l})", l=line)
        # TODO: flesh out
        if self.todo_arg and "TODO" in line:
            print(f"arg1 line ({self.line_num}): {line}")
        else:
            debug.trace(3, f"Ignoring line ({self.line_num}): {line}")
        ## TODO: regex pattern matching
        ## elif my_re.search(self.text_arg, line):
        ##     print("arg2 line: %s" % line)

    ## TODO: if no input proocessed, customize run_main_step instead
    ## and specify skip_input below
    ##
    ## def run_main_step(self):
    ##     """Main processing step"""
    ##     debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)
    ##

    ## TODO: def wrap_up(self):
    ##           """Do final processing"""
    ##           debug.trace(6, f"Script.wrap_up(); self={self}")
    ##           # ...

def main():
    """Entry point"""
    app = Script(
        description=__doc__.format(script=__file__),
        # Note: skip_input controls the line-by-line processing, which is inefficient but simple to
        # understand; in contrast, manual_input controls iterator-based input (the opposite of both).
        skip_input=False,
        manual_input=False,
        ## TODO (specify auto_help such as when manual_input set):
        ## # Note: shows brief usage if no arguments given
        ## auto_help=True,
        ## -or-: # Disable inference of --help argument
        ## auto_help=False,
        ## TODO: specify options and (required) arguments
        boolean_options=[(TODO_ARG, "TODO-desc")],
        ## TODO
        ## Note: FILENAME is default argument unless skip_input
        ## positional_arguments=[ALT_FILENAME], 
        ## text_options=[(TEXT_ARG, "TODO-desc")],
        ## Note: Following added for indentation float options not common (TODO: remove?)
        float_options=None)
    app.run()
    # Make sure no TODO_vars above (i.e., in namespace)
    debug.assertion(not any(my_re.search(r"^TODO_", m, my_re.IGNORECASE)
                            for m in dir(app)))    
    
#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"main __doc__: {main.__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()
