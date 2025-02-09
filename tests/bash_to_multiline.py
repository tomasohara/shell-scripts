#! /usr/bin/env python

"""
Transforms bash aliases and single-line functions into multiline format, preserving comments and structure.

Sample usage:
   {script} --input input.sh [--output output.sh]
"""

# Standard modules
from enum import Enum
from typing import List, Optional

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

    def _transform_alias(self, line: str) -> str:
        """Convert alias to multiline function"""
        match = my_re.match(r'''^alias\s+([a-zA-Z0-9_-]+)\s*=\s*(?:['"]?(.*)['"]?)$''', line.strip())
        if not match:
            return line
        alias_name, command_part = match.groups()
        return f'function {alias_name} {{\n    {command_part}\n}}\n'

    def _transform_singleline(self, line: str) -> str:
        """Convert single-line function to multiline format"""
        match = my_re.match(r'''(?:function\s+)?([a-zA-Z0-9_-]+)\s*\(\)\s*\{(.*)\}$''', line.strip())
        if not match:
            return line
        func_name, body = match.groups()
        parts = self._split_commands(body)
        indented_body = '\n    '.join(parts)
        return f"function {func_name}() {{\n    {indented_body}\n}}\n"

    def _split_commands(self, command_string: str) -> List[str]:
        """Split commands while preserving quotes and nested structures"""
        parts = []
        current = []
        in_quotes = False
        quote_char = None
        escaped = False
        brace_level = paren_level = 0

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
                if char == '{':
                    brace_level += 1
                elif char == '}':
                    brace_level -= 1
                elif char == '(':
                    paren_level += 1
                elif char == ')':
                    paren_level -= 1

            if char == ';' and not in_quotes and brace_level == 0 and paren_level == 0:
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

        try:
            for line in lines:
                analyzed = self._analyze_line(line)
                if analyzed.line_type == LineType.BLOCK_START:
                    block_level += 1
                    processed_lines.append(line)
                    continue
                if analyzed.line_type == LineType.BLOCK_END:
                    block_level -= 1
                    processed_lines.append(line)
                    continue
                if block_level > 0:
                    processed_lines.append(line)
                    continue

                if analyzed.line_type == LineType.CODE:
                    transformed = self._transform_alias(line)
                    if transformed == line:
                        transformed = self._transform_singleline(transformed)
                    processed_lines.append(transformed)
                elif analyzed.line_type == LineType.MIXED:
                    transformed = self._transform_alias(analyzed.code_part)
                    if transformed == analyzed.code_part:
                        transformed = self._transform_singleline(transformed)
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