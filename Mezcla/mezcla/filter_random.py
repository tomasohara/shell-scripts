#! /usr/bin/env python
# 
# Filters lines in input file, based on random numbers
# TODO: use iterator for input (see ???)
#

"""Filter lines randomly"""

# Standard packages
import random
import sys

# Installed packages
# TODO
#
# "local" packages (n.b., check for customized version)
from mezcla import debug
from mezcla.main import Main
from mezcla import system

INCLUDE_HEADER = "include-header"
RATIO = "ratio"
SEED = "seed"
QUIET_MODE = "quiet"
## TODO: ALT_TODO_ARG = "alt-todo-arg"
DEFAULT_RATIO = system.getenv_number("DEFAULT_RATIO", 0.10,
                                     "Ratio of input to use (i.e., percent/100)")
RANDOM_SEED = system.getenv_integer("RANDOM_SEED", 15485863,
                                    "Integral seed for randoom number generation")

class Filter(Main):
    """Input processing class"""
    include_header = False
    ratio = 0.10
    quiet_mode = False
    ## alt_todo_arg = ""

    def setup(self):
        """Process arguments"""
        self.include_header = self.get_parsed_option(INCLUDE_HEADER)
        self.ratio = self.get_parsed_option(RATIO)
        seed = self.get_parsed_option(SEED)
        if seed:
            random.seed(seed)
        self.quiet_mode = self.get_parsed_option(QUIET_MODE, self.quiet_mode)
        ## TODO: self.alt_todo_arg = self.get_parsed_option(alt_todo_arg, self.alt_todo_arg)
        debug.trace_object(6, self, "filter instance")
        debug.trace(4, "ratio={self.ratio}, seed={seed}")
        self.status("Settings:")
        self.status(f"Print header: {self.include_header}")
        self.status(f"Ratio: {self.ratio}")
        self.status(f"Random seed: {seed}")
        debug.trace_object(5, self, label="Filter instance")
        return

    def status(self, message):
        """Print MESSAGE on stderr unless self.quiet"""
        if not self.quiet_mode:
            print(message, file=sys.stderr)
        return
                  
    def process_line(self, line):
        """Processes current line from input (randomly printing)"""
        debug.trace(5, f"Filter.process_line({line})")
        include = ((random.random() <= self.ratio)
                   or ((self.line_num == 1) and (self.include_header)))
        debug.trace_expr(6, include)
        if include:
            print(line)
        return

if __name__ == '__main__':
    ## debug.trace_fmt(3, "Environment options: {eo}",
    ##                 eo=system.formatted_environment_option_descriptions())
    app = Filter(description=__doc__,
                 # TODO: use Main.read_input directly w/ manual_input=True
                 # TODO: mention USE_PARAGRAPH_MODE env. option
                 boolean_options=[(INCLUDE_HEADER, "Include header line"),
                                  (QUIET_MODE, "Don't print status messages")],
                 ## TODO: text_options=[(alt_todo_arg, "TODO-desc")],
                 float_options=[(RATIO, "Random threshold in range [0, 1] for lines to be incorporated", DEFAULT_RATIO), 
                                (SEED, "Random seed", RANDOM_SEED)])
    app.run()
