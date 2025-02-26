#! /usr/bin/env python

"""
Script to extract function definitions and aliases from a Bash script.

Sample usage:
   {script} --input script.bash [--output output.json]
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
INPUT_ARG = "input"
OUTPUT_ARG = "output"
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

        # Regex for function definitions
        FUNC_REGEX = re.compile(r"function\s+([\w-]+)\s*(\(\))?\s*\{")
        
        # Regex for alias definitions
        ALIAS_REGEX_SINGLE_QUOTE = re.compile(r"^alias\s+([a-zA-Z0-9_]+)='([^']*)'")
        ALIAS_REGEX_DOUBLE_QUOTE = re.compile(r'^alias\s+([a-zA-Z0-9_]+)="([^"]*)"')
        ALIAS_REGEX_NO_QUOTE = re.compile(r"^alias\s+([a-zA-Z0-9_]+)=([^\s]*)")

        for i, line in enumerate(script_content, 1):
            line = line.strip()

            if self.is_comment(line):
                continue

            # Check for function definitions
            func_match = FUNC_REGEX.match(line)
            if func_match:
                if function_name:
                    function_ranges[function_name]["end"] = i - 1
                function_name = func_match.group(1)
                start_line = i
                function_ranges[function_name] = {"start": start_line, "end": None}

            # Check for alias definitions
            alias_match_single = ALIAS_REGEX_SINGLE_QUOTE.match(line)
            alias_match_double = ALIAS_REGEX_DOUBLE_QUOTE.match(line)
            alias_match_no_quote = ALIAS_REGEX_NO_QUOTE.match(line)

            if alias_match_single:
                alias_name = alias_match_single.group(1)
                alias_def = alias_match_single.group(2)
                aliases.append({"name": alias_name, "definition": alias_def})
            elif alias_match_double:
                alias_name = alias_match_double.group(1)
                alias_def = alias_match_double.group(2)
                aliases.append({"name": alias_name, "definition": alias_def})
            elif alias_match_no_quote:
                alias_name = alias_match_no_quote.group(1)
                alias_def = alias_match_no_quote.group(2)
                aliases.append({"name": alias_name, "definition": alias_def})

        if function_name:
            function_ranges[function_name]["end"] = len(script_content)
        
        return {"functions": function_ranges, "aliases": aliases}

class BashExtractorScript(Main):
    """Main script class for Bash function/alias extraction."""
    
    def setup(self):
        """Initialize command-line options and helper instance."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        self.script_path = self.get_parsed_option(INPUT_ARG)
        self.output_path = self.get_parsed_option(OUTPUT_ARG)
        self.helper = BashFunctionAliasExtractor(self.script_path)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def run_main_step(self):
        """Main processing step."""
        debug.trace(5, f"Script.run_main_step(): self={self}")
        extracted_data = self.helper.extract_functions_aliases()
        
        # Print to stdout if no output file is specified
        if not self.output_path:
            print(json.dumps(extracted_data, indent=4))
        else:
            # Write to the specified output file
            try:
                with open(self.output_path, "w") as f:
                    json.dump(extracted_data, f, indent=4)
                print(f"Extracted data written to {self.output_path}")
            except IOError as e:
                system.print_stderr(f"Error writing to {self.output_path}: {e}")

def main():
    """Entry point."""
    app = BashExtractorScript(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        auto_help=True,
        text_options=[
            (INPUT_ARG, "Path to Bash script file"),
            (OUTPUT_ARG, "Path to output JSON file (optional)")
        ]
    )
    app.run()

if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()