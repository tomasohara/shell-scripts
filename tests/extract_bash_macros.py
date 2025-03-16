#! /usr/bin/env python

"""
Script to extract function definitions and aliases from a Bash script.

Sample usage:
   {script} input_script.bash
   cat input_script.bash | {script} > output.txt
   {script} --json input_script.bash > output.json
"""

# Standard modules
import json
import re
import datetime

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system

# Constants
TL = debug.TL
JSON_OUTPUT_OPT = "json"

class BashFunctionAliasExtractor:
    """Helper class for extracting function definitions and aliases from a Bash script."""
    
    def __init__(self, script_content):
        """Initializer: sets up the Bash script content."""
        debug.trace(TL.VERBOSE, f"BashFunctionAliasExtractor.__init__(): self={self}")
        self.script_content = script_content
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def is_comment(self, line):
        """Detects if a line is a comment."""
        return line.strip().startswith("#")
    
    def extract_functions_aliases(self):
        """Extracts function definitions and aliases from the script."""        
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

        for i, line in enumerate(self.script_content, 1):
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
                aliases.append({"name": alias_name, "definition": alias_def, "line": i})
            elif alias_match_double:
                alias_name = alias_match_double.group(1)
                alias_def = alias_match_double.group(2)
                aliases.append({"name": alias_name, "definition": alias_def, "line": i})
            elif alias_match_no_quote:
                alias_name = alias_match_no_quote.group(1)
                alias_def = alias_match_no_quote.group(2)
                aliases.append({"name": alias_name, "definition": alias_def, "line": i})

        if function_name:
            function_ranges[function_name]["end"] = len(self.script_content)
        
        return {"functions": function_ranges, "aliases": aliases}

class BashExtractorScript(Main):
    """Main script class for Bash function/alias extraction."""
    
    def __init__(self, *args, **kwargs):
        """Initialize script class"""
        super().__init__(*args, **kwargs)
        self.json_output = False
        self.script_lines = []
        self.input_file = "stdin"
        self.process_date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def setup(self):
        """Check results of command line processing"""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        self.json_output = self.get_parsed_option(JSON_OUTPUT_OPT, self.json_output)
    
    def process_line(self, line):
        """Process each line from the input - we'll accumulate all lines."""
        self.script_lines.append(line)
    
    def wrap_up(self):
        """Process all accumulated lines once input is complete."""
        debug.trace(TL.VERBOSE, f"BashExtractorScript.wrap_up(): Analyzing {len(self.script_lines)} lines")
        
        # Check if we have any lines to process
        if not self.script_lines:
            system.print_stderr("No input received. Please provide a Bash script.")
            return
            
        # Process the collected script
        helper = BashFunctionAliasExtractor(self.script_lines)
        extracted_data = helper.extract_functions_aliases()
        
        # Add metadata to the extracted data
        metadata = {
            "input_file": self.input_file,
            "process_date": self.process_date
        }
        
        # Output based on format selection
        if self.json_output:
            # Add metadata to JSON output
            extracted_data["metadata"] = metadata
            print(json.dumps(extracted_data, indent=4))
        else:
            # Output in tabulated format with metadata header
            self.print_simple_table_output(extracted_data, metadata)
    
    def print_simple_table_output(self, data, metadata):
        """Print the extracted data in a simple console table format."""
        # Print metadata header
        print("\nextract_bash_macros.py")
        print("=" * 50)
        print(f"Input File: {metadata['input_file']}")
        print(f"Timestamp: {metadata['process_date']}")
        print("=" * 50)
        
        # Define column headers
        function_headers = ["Function Name", "Start Line", "End Line"]
        alias_headers = ["Alias Name", "Definition", "Line"]
        
        # Format functions table
        function_rows = []
        for func_name, line_info in data["functions"].items():
            function_rows.append([func_name, str(line_info["start"]), str(line_info["end"])])
        
        # Format aliases table
        alias_rows = []
        for alias in data["aliases"]:
            alias_rows.append([alias["name"], alias["definition"], str(alias["line"])])
        
        # Print functions table
        print("\nFUNCTIONS:")
        self._print_table(function_headers, function_rows)
        
        # Print aliases table
        print("\nALIASES:")
        self._print_table(alias_headers, alias_rows)
    
    def _print_table(self, headers, rows):
        """Helper method to print a simple ASCII table."""
        if not rows:
            print("  No data available")
            return
            
        col_widths = [len(h) for h in headers]
        for row in rows:
            for i, cell in enumerate(row):
                col_widths[i] = max(col_widths[i], len(cell))
        
        fmt = '  '.join('{{:{}}}'.format(w) for w in col_widths)
        
        print(fmt.format(*headers))
        print('-' * (sum(col_widths) + 2 * (len(headers) - 1)))
        
        # Print the rows
        for row in rows:
            print(fmt.format(*row))

def main():
    """Entry point."""
    app = BashExtractorScript(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=False,
        manual_input=False,
        auto_help=True,
        boolean_options=[
            (JSON_OUTPUT_OPT, "Print JSON output instead of tabulated output")
        ]
    )
    app.run()

if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()