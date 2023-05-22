#! /usr/bin/env python
# 
# TODO what the script does (detailed)
#
# The software is Open Source, licensed under the GNU Lesser General Public Version 3 (LGPLv3). See LICENSE.txt in repository.
#
## TODO: see example/template.py for simpler version suitable for cut-n-paste from online examples
#

"""TODO: what module does (brief)"""

# Standard modules
import re

# Installed modules
## TODO: import numpy

# Local modules
# TODO: def mezcla_import(name): ... components = eval(name).split(); ... import nameN-1.nameN as nameN
from mezcla import debug
from mezcla.main import Main
from mezcla import system
## TODO:
## from mezcla.my_regex import my_re
## from mezcla import glue_helpers as gh

## TODO: Constants for switches omitting leading dashes (e.g., DEBUG_MODE = "debug-mode")
## Note: Run following in Emacs to interactively replace TODO_ARG with option label
##    M-: (query-replace-regexp "todo\\([-_]\\)arg" "arg\\1name")
## where M-: is the emacs keystroke short-cut for eval-expression.
TODO_ARG = "TODO-arg"
## ALT_TODO_ARG = "alt-todo-arg"
## TODO_FILENAME = "TODO-filename"

## TODO:
## # Environment options
## # Note: These are just intended for internal options, not for end users.
## # It also allows for enabling options in one place rather than four
## # (e.g., [Main member] initialization, run-time value, and argument spec., along
## # with string constant definition).
## #
## FUBAR = system.getenv_bool("FUBAR", False,
##                            description="Fouled Up Beyond All Recognition processing")


class Script(Main):
    """Input processing class"""
    # TODO: -or-: """Adhoc script class (e.g., no I/O loop, just run calls)"""
    ## TODO: class-level member variables for arguments (avoids need for class constructor)
    todo_arg = False
    ## alt_todo_arg = ""

    # TODO: add class constructor if needed for non-standard initialization
    ## def __init__(self, *args, **kwargs):
    ##     debug.trace_fmtd(5, "Script.__init__({a}): keywords={kw}; self={s}",
    ##                      a=",".join(args), kw=kwargs, s=self)
    ##     super(Script, self).__init__(*args, **kwargs)
    
    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        ## TODO: extract argument values
        self.todo_arg = self.get_parsed_option(TODO_ARG, self.todo_arg)
        ## self.alt_todo_arg = self.get_parsed_option(alt_todo_arg, self.alt_todo_arg)
        # TODO: self.TODO_filename = self.get_parsed_argument(TODO_FILENAME)
        debug.trace_object(5, self, label="Script instance")

    def process_line(self, line):
        """Processes current line from input"""
        debug.trace_fmtd(6, "Script.process_line({l})", l=line)
        # TODO: flesh out
        if self.todo_arg and "TODO" in line:
            print("arg1 line ({n}): {l}".format(n=self.line_num, l=line))
        ## TODO: regex pattern matching
        ## elif my_re.search(self.alt_todo_arg, line):
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

#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    debug.trace_fmt(4, "Environment options: {eo}",
                    eo=system.formatted_environment_option_descriptions())
    app = Script(
        description=__doc__,
        # Note: skip_input controls the line-by-line processing, which is inefficient but simple to
        # understand; in contrast, manual_input controls iterator-based input (the opposite of both).
        skip_input=False,
        manual_input=False,
        # TODO: Disable inference of --help argument
        ## auto_help=False,
        ## TODO: specify options and (required) arguments
        boolean_options=[(TODO_ARG, "TODO-desc")],
        # Note: FILENAME is default argument unless skip_input
        ## positional_arguments=[FILENAME1, FILENAME2], 
        ## text_options=[(alt_todo_arg, "TODO-desc")],
        # Note: Following added for indentation: float options are not common
        float_options=None)
    app.run()
    debug.assertion(not any(re.search(r"^TODO_", m, re.IGNORECASE)
                            for m in dir(app)))
