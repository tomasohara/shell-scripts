#! /usr/bin/env python

"""
Script to extract function definitions and aliases from a Bash script.

Sample usage:
   {script} --bash-script=script.bash
"""

# Standard modules
import json
import re

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

# Constants
BASH_SCRIPT = "bash-script"
TL = debug.TL

class BashFunctionAliasExtractor:
    """Helper class for extracting function definitions and aliases from a Bash script."""
    
    def __init__(self, script_path):
        """Initializer: sets up the Bash script path."""
        debug.trace(TL.VERBOSE, f"BashFunctionAliasExtractor.__init__(): self={self}")
        self.script_path = script_path
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def is_comment(self, line):
        """Detects if a line is a comment."""
        return line.strip().startswith("#")
    
    def extract_functions_aliases(self):
        """Extracts function definitions and aliases from the script."""        
        script_content = gh.read_lines(self.script_path)
        
        function_ranges = {}
        aliases = []
        function_name = None
        start_line = None

        FUNC_REGEX = re.compile(r"function\s+([\w-]+)\s*(\(\))?\s*\{")
        ALIAS_REGEX = re.compile(r"^alias\s+([a-zA-Z0-9_]+)=")

        for i, line in enumerate(script_content, 1):
            line = line.strip()

            if self.is_comment(line):
                continue

            func_match = FUNC_REGEX.match(line)
            if func_match:
                if function_name:
                    function_ranges[function_name]["end"] = i - 1
                function_name = func_match.group(1)
                start_line = i
                function_ranges[function_name] = {"start": start_line, "end": None}

            alias_match = ALIAS_REGEX.match(line)
            if alias_match:
                aliases.append(alias_match.group(1))

        if function_name:
            function_ranges[function_name]["end"] = len(script_content)
        
        return {"functions": function_ranges, "aliases": aliases}

class BashExtractorScript(Main):
    """Main script class for Bash function/alias extraction."""
    
    def setup(self):
        """Initialize command-line options and helper instance."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        self.script_path = self.get_parsed_option(BASH_SCRIPT)
        self.helper = BashFunctionAliasExtractor(self.script_path)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def run_main_step(self):
        """Main processing step."""
        debug.trace(5, f"Script.run_main_step(): self={self}")
        extracted_data = self.helper.extract_functions_aliases()
        print(json.dumps(extracted_data, indent=4))

def main():
    """Entry point."""
    app = BashExtractorScript(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        auto_help=True,
        text_options=[
            (BASH_SCRIPT, "Path to Bash script file")
        ]
    )
    app.run()

if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()
