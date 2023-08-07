#! /usr/bin/env python
# 
# Sample script using Main class. By default, this outputs lines that contain
# "fubar". There is an option to check for lines matching a regular expression.
#

"""Simple illustration of Main class"""

# Standard packages
import re

# Local packages
from mezcla import debug
from mezcla.main import Main

class Script(Main):
    """Input processing class"""
    regex = None
    check_fubar = None

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        self.regex = self.parsed_args['regex']
        self.check_fubar = self.get_parsed_option('check-fubar', not self.regex)
        debug.assertion(bool(self.regex) ^ self.check_fubar)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def process_line(self, line):
        """Processes current line from input"""
        debug.trace_fmtd(6, "Script.process_line({l})", l=line)
        if self.check_fubar and "fubar" in line:
            debug.trace(4, f"Fubar line {self.line_num}: {line}")
            print(line)
        elif self.regex and re.search(self.regex, line):
            debug.trace(4, f"Regex line {self.line_num}: {line}")
            print(line)
        return

if __name__ == '__main__':
    ## TODO: app => script???
    app = Script(description=__doc__,
                 boolean_options=["check-fubar"],
                 text_options=[("regex", "Regular expression")])
    app.run()
