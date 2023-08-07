#! /usr/bin/env python
#
# Module for using Python abstract syntax tree (AST) support
# 
#

"""
Wrapper around AST. This is intended mainly for internal use, but a command-line example folows:

Sample usage:
   {script} __init__.py
"""

# Standard modules
import ast

# Installed modules
## TODO: import numpy

# Local modules
from mezcla import debug
from mezcla.main import Main
from mezcla import system
debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

# Constants for switches omitting leading dashes (e.g., DEBUG_MODE = "debug-mode")
TYPE_COMMENTS = "type-comments"

# Constants
TL = debug.TL

# Environment options
# Note: These are just intended for internal options, not for end users.
#
TODO_FUBAR = system.getenv_bool("TODO_FUBAR", False,
                                description="TODO:Fouled Up Beyond All Recognition processing")

class PythonAST:
    """Wrapper class around ast module"""

    def __init__(self, add_type_comments=None):
        """Initializer: optionally ADD_TYPE_COMMENTS"""
        debug.trace_fmtd(TL.VERBOSE, "PythonAST.__init__(): self={s}", s=self)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
        self.ast = None
        self.type_comments = add_type_comments

    def parse(self, python_code):
        """Parse PYTHON_CODE in AST"""
        self.ast = None
        try:
            self.ast = ast.parse(python_code, type_comments=self.type_comments)
        except:
            system.print_exception_info("parse")
        debug.trace_fmt(4, "parse({c}) => {p!r}", c=python_code, p=self.ast)
        return self.ast

    def dump(self):
        """Dump the AST into a string"""
        debug.assertion(self.ast)
        dump_text = ""
        try:
            dump_text = ast.dump(self.ast)
        except:
            system.print_exception_info("dump")
        debug.trace_fmt(4, "dump() => {d!r}", d=dump_text)
        return dump_text
        

class Script(Main):
    """Input processing class"""
    show_type_comments = False

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(TL.VERBOSE, "Script.setup(): self={s}", s=self)
        self.show_type_comments = self.get_parsed_option(TYPE_COMMENTS, self.show_type_comments)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)
        input_python = self.read_entire_input()
        python_ast = PythonAST(add_type_comments=self.show_type_comments)
        python_ast.parse(input_python)
        print(python_ast.dump())


def main():
    """Entry point"""
    app = Script(
        description=__doc__.format(script=__file__),
        # note: reads entire file at once so manual input used (via run_main_step)
        skip_input=False, manual_input=True,
        boolean_options=[(TYPE_COMMENTS, "Include AST type comments")])
    app.run()
    
#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()
