#! /usr/bin/env python

"""
Bash Function Converter

This script scans Bash files and converts aliases and single-line functions 
to proper multi-line functions using an object-oriented approach.
All converted functions use the 'function' keyword to support hyphenated names.
It also removes empty sections of curly braces that don't contain functions.

Sample usage:
   ./bash_converter.py input.bash > output.bash
   cat input.bash | ./bash_converter.py --print-stats -- > output.bash
"""

# Standard modules
import re
import sys

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

# Constants for switches
PRINT_STATS = "print-stats"
PRESERVE_ALIASES = "preserve-aliases"
VERBOSE_MODE = "verbose"
FUNCTION_KEYWORD = "function-keyword"
REMOVE_EMPTY_BLOCKS = "remove-empty-blocks"

# Constants
TL = debug.TL

# Environment options
PRESERVE_COMMENTS = system.getenv_bool(
    "PRESERVE_COMMENTS", True,
    description="Preserve comments in converted functions")

class BashFunction:
    """Class representing a Bash function with parsing and conversion capabilities"""
    
    def __init__(self, name, body, is_alias=False, source_line=None, use_function_keyword=True):
        """Initialize with function name and body"""
        debug.trace(TL.VERBOSE, f"BashFunction.__init__(): name={name}, is_alias={is_alias}")
        self.name = name
        self.body = body.strip()
        self.is_alias = is_alias
        self.source_line = source_line
        self.use_function_keyword = use_function_keyword
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def to_multiline(self):
        """Convert to multi-line function format with function keyword"""
        if self.is_alias:
            # Convert alias to function with function keyword
            body_lines = self.body.split(";")
            indented_body = "\n    ".join(line.strip() for line in body_lines if line.strip())
            if self.use_function_keyword:
                return f"function {self.name} {{\n    {indented_body}\n}}"
            else:
                return f"{self.name}() {{\n    {indented_body}\n}}"
        else:
            # Convert single-line function to multi-line
            # Extract the body which is between { and }
            body_match = my_re.search(r'{(.*)}', self.body)
            if body_match:
                body = body_match.group(1).strip()
                body_lines = body.split(";")
                indented_body = "\n    ".join(line.strip() for line in body_lines if line.strip())
                if self.use_function_keyword:
                    # Use function keyword format
                    return f"function {self.name} {{\n    {indented_body}\n}}"
                else:
                    # Use traditional format
                    return f"{self.name}() {{\n    {indented_body}\n}}"
            return self.body  # Return unchanged if format not recognized
    
    def __str__(self):
        """String representation"""
        return f"{'Alias' if self.is_alias else 'Function'}: {self.name} => {self.body}"


class BashParser:
    """Parser for Bash files to extract functions and aliases"""
    
    def __init__(self, use_function_keyword=True):
        """Initialize parser with regex patterns"""
        debug.trace(TL.VERBOSE, f"BashParser.__init__()")
        self.use_function_keyword = use_function_keyword
        
        # Regex for single line function in two formats:
        # 1. function_name() { commands; }
        # 2. function function_name { commands; }
        self.single_line_func_patterns = [
            re.compile(r'^(\s*)([a-zA-Z0-9_-]+)\(\)\s*{\s*(.+?)\s*}\s*$'),
            re.compile(r'^(\s*)function\s+([a-zA-Z0-9_-]+)\s*{\s*(.+?)\s*}\s*$')
        ]
        
        # Regex patterns for aliases:
        # 1. alias name=command
        # 2. alias name='command'
        # 3. alias 'name=command'
        self.alias_patterns = [
            re.compile(r'^(\s*)alias\s+([a-zA-Z0-9_-]+)=([\w-]+)(\s*#.*)?$'),
            re.compile(r'^(\s*)alias\s+([a-zA-Z0-9_-]+)=[\'\"](.+?)[\'\"](\s*#.*)?$'),
            re.compile(r'^(\s*)alias\s+[\'\"]([a-zA-Z0-9_-]+)=([\w-]+)[\'\"](\s*#.*)?$')
        ]
        
        # Regex pattern for empty blocks
        self.open_brace_pattern = re.compile(r'^\s*{\s*(?:#.*)?$')
        self.close_brace_pattern = re.compile(r'^\s*}\s*(?:#.*)?$')
        
        self.functions = []
        self.aliases = []
        self.line_count = 0
        
        # Track braces for empty block detection
        self.open_brace_lines = []
        self.blocks = []  # (start_line, end_line, content_lines)
        
        # Store all lines for post-processing
        self.all_lines = []
        
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def parse_line(self, line):
        """Parse a single line to identify functions and aliases"""
        debug.trace_fmtd(TL.QUITE_DETAILED, "BashParser.parse_line({l})", l=line)
        self.line_count += 1
        self.all_lines.append(line)
        
        # Try to match a single-line function with either pattern
        for pattern in self.single_line_func_patterns:
            func_match = pattern.match(line)
            if func_match:
                indent, name, body = func_match.groups()
                func = BashFunction(
                    name, 
                    f"{{ {body} }}", 
                    is_alias=False, 
                    source_line=self.line_count,
                    use_function_keyword=self.use_function_keyword
                )
                self.functions.append(func)
                debug.trace(3, f"Found single-line function: {name}")
                return True
        
        # Try to match aliases using the different patterns
        for pattern in self.alias_patterns:
            alias_match = pattern.match(line)
            if alias_match:
                groups = alias_match.groups()
                indent = groups[0]
                name = groups[1]
                command = groups[2]
                comment = groups[3] if len(groups) > 3 else None
                
                alias = BashFunction(
                    name, 
                    command, 
                    is_alias=True, 
                    source_line=self.line_count,
                    use_function_keyword=self.use_function_keyword
                )
                self.aliases.append(alias)
                debug.trace(3, f"Found alias: {name} = {command}")
                return True
        
        # Track braces for empty block detection
        if self.open_brace_pattern.match(line):
            debug.trace(4, f"Found opening brace at line {self.line_count}")
            self.open_brace_lines.append(self.line_count)
        elif self.close_brace_pattern.match(line) and self.open_brace_lines:
            start_line = self.open_brace_lines.pop()
            debug.trace(4, f"Found closing brace at line {self.line_count}, matching line {start_line}")
            # Store block info for post-processing
            self.blocks.append((start_line, self.line_count, self.line_count - start_line - 1))
        
        return False
    
    def identify_empty_blocks(self):
        """Identify truly empty blocks (only comments or whitespace)"""
        empty_blocks = []
        
        for start_line, end_line, content_lines in self.blocks:
            # Check if there's only comments or whitespace between braces
            if content_lines == 0:
                # Empty block with no lines between braces
                empty_blocks.append((start_line, end_line))
                continue
                
            block_content = self.all_lines[start_line:end_line-1]
            only_comments = True
            
            for line in block_content:
                stripped = line.strip()
                if stripped and not stripped.startswith('#'):
                    # Found non-comment content
                    only_comments = False
                    break
            
            if only_comments:
                empty_blocks.append((start_line, end_line))
                debug.trace(3, f"Empty block found from line {start_line} to {end_line}")
        
        return empty_blocks
    
    def get_stats(self):
        """Return statistics about parsed content"""
        empty_blocks = self.identify_empty_blocks()
        return {
            "functions": len(self.functions),
            "aliases": len(self.aliases),
            "empty_blocks": len(empty_blocks),
            "lines": self.line_count
        }


class Script(Main):
    """Script class for processing Bash files"""
    print_stats = False
    preserve_aliases = False
    verbose = False
    function_keyword = True
    remove_empty_blocks = True

    def setup(self):
        """Check results of command line processing"""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        self.print_stats = self.get_parsed_option(PRINT_STATS, self.print_stats)
        self.preserve_aliases = self.get_parsed_option(PRESERVE_ALIASES, self.preserve_aliases)
        self.verbose = self.get_parsed_option(VERBOSE_MODE, self.verbose)
        self.function_keyword = self.get_parsed_option(FUNCTION_KEYWORD, self.function_keyword)
        self.remove_empty_blocks = self.get_parsed_option(REMOVE_EMPTY_BLOCKS, self.remove_empty_blocks)
        
        # Initialize parser
        self.parser = BashParser(use_function_keyword=self.function_keyword)
        
        # Track lines to replace or remove
        self.lines_to_replace = {}
        self.all_input_lines = []
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def process_line(self, line):
        """Process each line from the input file"""
        debug.trace_fmtd(TL.QUITE_DETAILED, "Script.process_line({l})", l=line)
        
        # Store all input lines for post-processing
        self.all_input_lines.append(line)
        
        # Parse the line to identify functions and aliases
        is_match = self.parser.parse_line(line)
        
        # Mark line for replacement if it's a match
        if is_match:
            self.lines_to_replace[self.line_num] = line
            if self.verbose:
                print(f"# Line {self.line_num} will be converted")
    
    def wrap_up(self):
        """Process the identified functions and aliases"""
        debug.trace(6, f"Script.wrap_up(); self={self}")
        
        # If no empty block removal, process line by line
        if not self.remove_empty_blocks:
            self._process_line_by_line()
            return
        
        # Otherwise process with empty block removal
        self._process_with_block_removal()
    
    def _process_line_by_line(self):
        """Process line by line without empty block removal"""
        for line_num, line in enumerate(self.all_input_lines, 1):
            if line_num in self.lines_to_replace:
                # Get the function or alias to convert
                converted = False
                
                # Check functions
                for func in self.parser.functions:
                    if func.source_line == line_num:
                        print(func.to_multiline())
                        converted = True
                        break
                
                # Check aliases if not already converted
                if not converted:
                    for alias in self.parser.aliases:
                        if alias.source_line == line_num:
                            if self.preserve_aliases:
                                print(line)
                            else:
                                print(alias.to_multiline())
                            converted = True
                            break
                
                # Fallback if somehow not converted
                if not converted:
                    print(line)
            else:
                print(line)
    
    def _process_with_block_removal(self):
        """Process with empty block removal"""
        # Get empty blocks
        empty_blocks = self.parser.identify_empty_blocks()
        lines_to_skip = set()
        
        # Mark lines in empty blocks to be skipped
        for start_line, end_line in empty_blocks:
            for i in range(start_line, end_line + 1):
                lines_to_skip.add(i)
        
        # Process lines
        for line_num, line in enumerate(self.all_input_lines, 1):
            # Skip lines that are part of empty blocks
            if line_num in lines_to_skip:
                if self.verbose:
                    debug.trace(3, f"Skipping line {line_num} (part of empty block)")
                continue
            
            # Process line for conversion or output as-is
            if line_num in self.lines_to_replace:
                # Get the function or alias to convert
                converted = False
                
                # Check functions
                for func in self.parser.functions:
                    if func.source_line == line_num:
                        print(func.to_multiline())
                        converted = True
                        break
                
                # Check aliases if not already converted
                if not converted:
                    for alias in self.parser.aliases:
                        if alias.source_line == line_num:
                            if self.preserve_aliases:
                                print(line)
                            else:
                                print(alias.to_multiline())
                            converted = True
                            break
                
                # Fallback
                if not converted:
                    print(line)
            else:
                print(line)
        
        # Print statistics if requested
        if self.print_stats:
            stats = self.parser.get_stats()
            print(f"\n# Conversion statistics:", file=sys.stderr)
            print(f"# Functions converted: {stats['functions']}", file=sys.stderr)
            print(f"# Aliases {'' if self.preserve_aliases else 'converted'}: {stats['aliases']}", file=sys.stderr)
            print(f"# Empty blocks removed: {stats['empty_blocks']}", file=sys.stderr)
            print(f"# Total lines processed: {stats['lines']}", file=sys.stderr)

def main():
    """Entry point"""
    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=False,
        manual_input=False,
        auto_help=True,
        boolean_options=[
            (PRINT_STATS, "Print statistics about conversions"),
            (PRESERVE_ALIASES, "Keep aliases instead of converting them"),
            (VERBOSE_MODE, "Show verbose output during processing"),
            (FUNCTION_KEYWORD, "Use 'function' keyword in converted functions (default: True)")
        ]
    )
    app.run()


if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()