#! /usr/bin/env python

"""
Transforms bash aliases and single-line functions into multiline format, preserving comments and structure.

Sample usage:
   {script} --input input.sh [--output output.sh]
"""

# Standard modules
from enum import Enum
from typing import List, Optional, Tuple
import re

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

# Constants
TL = debug.TL
INPUT_ARG = "input"
OUTPUT_ARG = "output"

class LineType(Enum):
    """Enum for line types in bash scripts"""
    CODE = "code"
    COMMENT = "comment"
    EMPTY = "empty"
    MIXED = "mixed"
    BLOCK_START = "block_start"
    BLOCK_END = "block_end"

class MultilineHelper:
    """Helper class for transforming single-line functions and aliases to multi-line function"""
    
    def __init__(self, input_path: str, output_path: Optional[str] = None):
        """Initialize with input and optional output paths"""
        debug.trace(TL.VERBOSE, f"MultilineHelper.__init__(): self={self}")
        self.input_path = input_path
        self.output_path = output_path
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def _handle_fully_quoted_alias(self, alias_string: str) -> Tuple[bool, str]:
        """Handle aliases where both the name and value are fully quoted: alias 'name'='value' or alias "name"="value" """
        match = my_re.match(r'''^\s*['"]([a-zA-Z0-9_\-:]+)['"]\s*=\s*['"](.*?)['"]\s*$''', alias_string)
        if match:
            alias_name, alias_value = match.groups()
            return True, self._create_function_from_alias(alias_name, alias_value)
        return False, alias_string

    def _analyze_line(self, line: str) -> 'Line':
        """Analyze a line and determine its type and components"""
        stripped = line.strip()

        if not stripped:
            return Line(line, LineType.EMPTY)
        if stripped == '{':
            return Line(line, LineType.BLOCK_START)
        if stripped == '}':
            return Line(line, LineType.BLOCK_END)
        if stripped.startswith('#'):
            return Line(line, LineType.COMMENT)

        in_quotes = False
        quote_char = None
        escaped = False

        for i, char in enumerate(line):
            if escaped:
                escaped = False
                continue
            if char == '\\':
                escaped = True
                continue
            if char in '"\'':
                if not in_quotes:
                    in_quotes = True
                    quote_char = char
                elif char == quote_char:
                    in_quotes = False
                    quote_char = None
            if char == '#' and not in_quotes:
                return Line(line, LineType.MIXED, line[:i].rstrip(), line[i:])

        return Line(line, LineType.CODE, line, "")
    
    def _handle_singlequote_alias(self, alias_string: str) -> Tuple[bool, str]:
        """Handle aliases with single quotes: alias name='value'"""
        match = my_re.match(r'''^\s*([a-zA-Z0-9_\-:]+)\s*=\s*'(.*?)'\s*$''', alias_string)
        if match:
            alias_name, alias_value = match.groups()
            return True, self._create_function_from_alias(alias_name, alias_value)
        return False, alias_string
    
    def _handle_doublequote_alias(self, alias_string: str) -> Tuple[bool, str]:
        """Handle aliases with double quotes: alias name="value" """
        match = my_re.match(r'''^\s*([a-zA-Z0-9_\-:]+)\s*=\s*"(.*?)"\s*$''', alias_string)
        if match:
            alias_name, alias_value = match.groups()
            return True, self._create_function_from_alias(alias_name, alias_value)
        return False, alias_string
    
    def _handle_noquote_alias(self, alias_string: str) -> Tuple[bool, str]:
        """Handle aliases without quotes: alias name=value"""
        match = my_re.match(r'''^\s*([a-zA-Z0-9_\-:]+)\s*=\s*(.+?)\s*$''', alias_string)
        if match:
            alias_name, alias_value = match.groups()
            return True, self._create_function_from_alias(alias_name, alias_value)
        return False, alias_string   
    
    def _handle_enclosed_alias(self, alias_string: str) -> Tuple[bool, str]:
        """Handle fully enclosed aliases: alias 'name=value' or alias "name=value" """
        # Check if the alias is fully enclosed in single or double quotes
        if ((alias_string.startswith("'") and alias_string.endswith("'")) or
            (alias_string.startswith('"') and alias_string.endswith('"'))):
            
            # Extract the content between quotes
            content = alias_string[1:-1].strip()
            equal_pos = content.find("=")
            
            if equal_pos != -1:
                alias_name = content[:equal_pos].strip()
                alias_value = content[equal_pos + 1:].strip()
                return True, self._create_function_from_alias(alias_name, alias_value)
        
        return False, alias_string
    
    def _transform_alias(self, line: str) -> str:
        """Convert alias to a properly formatted multiline function using specialized handlers"""
        line = line.strip()

        if not line.startswith("alias "):
            return line

        alias_string = line[6:].strip()
        
        handlers = [
            self._handle_fully_quoted_alias,  # New handler for fully quoted aliases
            self._handle_enclosed_alias,
            self._handle_singlequote_alias,
            self._handle_doublequote_alias,
            self._handle_noquote_alias
        ]
        
        for handler in handlers:
            handled, result = handler(alias_string)
            if handled:
                return result
        
        return line
    
    def _create_function_from_alias(self, alias_name: str, alias_value: str) -> str:
        """Create a multiline function from an alias name and value."""
        # Check if the alias name contains special characters that would be problematic in function names
        valid_func_name = alias_name
        
        # If the alias name contains special characters like ':', escape or modify it for the function name
        if not my_re.match(r'^[a-zA-Z0-9_\-]+$', alias_name):
            # Option 1: Replace problematic characters with underscores
            valid_func_name = re.sub(r'[^a-zA-Z0-9_\-]', '_', alias_name)
            
        # Split the alias value into individual commands
        commands = self._split_commands(alias_value)
        
        # Format the commands for the multiline function
        if len(commands) == 1 and commands[0].strip():
            # Single command
            formatted_commands = commands[0]
        else:
            # Multiple commands - join with newlines and indent
            formatted_commands = "\n    ".join(cmd.strip() for cmd in commands if cmd.strip())
        
        # Construct the multiline function, preserving any dashes in the name
        return f"function {valid_func_name}() {{\n    {formatted_commands}\n}}\n"
    
    def _transform_singleline(self, line: str) -> str:
        """Convert single-line function to multiline format"""
        # New improved regex pattern to match various single-line function formats
        patterns = [
            # Standard function with explicit 'function' keyword
            r'''function\s+([a-zA-Z0-9_-]+)\s*\(\)\s*\{\s*(.*)\s*\}\s*$''',
            
            # Function without explicit 'function' keyword
            r'''([a-zA-Z0-9_-]+)\s*\(\)\s*\{\s*(.*)\s*\}\s*$''',
            
            # Function with whitespace before the closing brace
            r'''function\s+([a-zA-Z0-9_-]+)\s*\(\)\s*\{\s*(.*?)\s*\}\s*$''',
            
            # Function with whitespace before the closing brace without 'function' keyword
            r'''([a-zA-Z0-9_-]+)\s*\(\)\s*\{\s*(.*?)\s*\}\s*$'''
        ]
        
        for pattern in patterns:
            match = my_re.match(pattern, line.strip())
            if match:
                func_name, body = match.groups()
                parts = self._split_commands(body)
                indented_body = '\n    '.join(part.strip() for part in parts if part.strip())
                return f"function {func_name}() {{\n    {indented_body}\n}}"
        
        return line

    def _split_commands(self, command_string: str) -> List[str]:
        """Split commands while preserving quotes and nested structures"""
        parts = []
        current = []
        in_quotes = False
        quote_char = None
        escaped = False
        brace_level = paren_level = 0
        in_command_subst = False

        for char in command_string:
            if escaped:
                current.append(char)
                escaped = False
                continue
            if char == '\\':
                current.append(char)
                escaped = True
                continue
            if char in '"\'':
                if not in_quotes:
                    in_quotes = True
                    quote_char = char
                elif char == quote_char:
                    in_quotes = False
                    quote_char = None
            elif not in_quotes:
                if char == '$' and len(command_string) > len(current) and command_string[len(current) + 1] == '(':
                    in_command_subst = True
                elif char == '(':
                    if not in_command_subst:
                        paren_level += 1
                elif char == ')':
                    if in_command_subst:
                        in_command_subst = False
                    else:
                        paren_level -= 1
                elif char == '{':
                    brace_level += 1
                elif char == '}':
                    brace_level -= 1

            if char == ';' and not in_quotes and not in_command_subst and brace_level == 0 and paren_level == 0:
                parts.append(''.join(current).strip())
                current = []
            else:
                current.append(char)

        if current:
            parts.append(''.join(current).strip())
        return parts

    def transform_script(self) -> int:
        """Transform bash script content"""
        try:
            lines = gh.read_lines(self.input_path)
        except (FileNotFoundError, PermissionError, IOError) as e:
            print(f"File error: {e}", file=system.print_stderr)
            return 1

        processed_lines = []
        block_level = 0
        
        # Track if we're inside a multiline function definition
        in_function = False

        try:
            for line in lines:
                # Fix spacing issues in bash syntax
                if "$#" in line:
                    line = line.replace("$ #", "$#")
                
                analyzed = self._analyze_line(line)
                
                # Check if we're entering or exiting a function definition
                if analyzed.line_type == LineType.CODE:
                    # Check if this line starts a multiline function
                    if (my_re.search(r'function\s+[a-zA-Z0-9_-]+\s*\(\)\s*\{[^}]*$', line) or
                        my_re.search(r'[a-zA-Z0-9_-]+\s*\(\)\s*\{[^}]*$', line)):
                        in_function = True
                
                if analyzed.line_type == LineType.BLOCK_END and in_function:
                    in_function = False
                
                # If we're inside a function or a block, don't transform
                if in_function or block_level > 0:
                    processed_lines.append(line)
                    
                    if analyzed.line_type == LineType.BLOCK_START:
                        block_level += 1
                    elif analyzed.line_type == LineType.BLOCK_END:
                        block_level -= 1
                        
                    continue
                
                if analyzed.line_type == LineType.BLOCK_START:
                    block_level += 1
                    processed_lines.append(line)
                    continue
                if analyzed.line_type == LineType.BLOCK_END:
                    block_level -= 1
                    processed_lines.append(line)
                    continue

                if analyzed.line_type == LineType.CODE:
                    # First check if it's a single line function, then check if it's an alias
                    transformed = self._transform_singleline(line)
                    if transformed == line:
                        transformed = self._transform_alias(transformed)
                    processed_lines.append(transformed)
                elif analyzed.line_type == LineType.MIXED:
                    # First check if it's a single line function, then check if it's an alias
                    transformed = self._transform_singleline(analyzed.code_part)
                    if transformed == analyzed.code_part:
                        transformed = self._transform_alias(transformed)
                    if transformed != analyzed.code_part:
                        transformed = transformed.rstrip('\n') + ' ' + analyzed.comment_part + '\n'
                    else:
                        transformed = line
                    processed_lines.append(transformed)
                else:
                    processed_lines.append(line)
        except (AttributeError, TypeError, KeyError) as e:
            print(f"Processing error: {e}", file=system.print_stderr)
            return 1

        if self.output_path:
            try:
                gh.write_lines(self.output_path, processed_lines)
                print(f"Transformed bash script written to {self.output_path}")
            except (PermissionError, IOError) as e:
                print(f"File write error: {e}", file=system.print_stderr)
                return 1
        else:
            for line in processed_lines:
                print(line, end='')

        return 0

class Line:
    """Class representing a line in a bash script"""
    def __init__(self, content: str, line_type: LineType, code_part: str = "", comment_part: str = ""):
        self.content = content
        self.line_type = line_type
        self.code_part = code_part
        self.comment_part = comment_part

class BashToMultiline(Main):
    """Bash script transformation class"""
    input_file = None
    output_file = None

    def setup(self):
        """Check results of command line processing"""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        self.input_file = self.get_parsed_option(INPUT_ARG, self.input_file)
        self.output_file = self.get_parsed_option(OUTPUT_ARG, self.output_file)
        self.helper = MultilineHelper(self.input_file, self.output_file)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def run_main_step(self):
        """Main processing step"""
        debug.trace(5, f"Script.run_main_step(): self={self}")
        if not self.input_file:
            print("Error: Input file is required")
            return 1
        return self.helper.transform_script()

def main():
    """Entry point"""
    app = BashToMultiline(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        auto_help=True,
        text_options=[
            (INPUT_ARG, "Input bash script file"),
            (OUTPUT_ARG, "Output file path (optional)")
        ])
    app.run()

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()