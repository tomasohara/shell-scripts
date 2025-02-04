import re
import sys
import argparse
from pathlib import Path
from enum import Enum
from typing import List, Optional

class LineType(Enum):
    CODE = "code"
    COMMENT = "comment"
    EMPTY = "empty"
    MIXED = "mixed"
    BLOCK_START = "block_start"
    BLOCK_END = "block_end"

class Line:
    def __init__(self, content: str, line_type: LineType, code_part: str = "", comment_part: str = ""):
        self.content = content
        self.line_type = line_type
        self.code_part = code_part
        self.comment_part = comment_part

class BashTransformer:
    def __init__(self, input_path: Path, output_path: Optional[Path] = None):
        """
        Initialize the BashTransformer with input and output paths.
        
        :param input_path: Path to the input bash script
        :param output_path: Optional path to write the transformed script
        """
        self.input_path = input_path
        self.output_path = output_path
        self.processed_lines: List[str] = []

    def analyze_line(self, line: str) -> Line:
        """
        Analyze a line and determine its type and components.
        
        :param line: Line of text to analyze
        :return: Line object with type and parts
        """
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
                code = line[:i].rstrip()
                comment = line[i:]
                return Line(line, LineType.MIXED, code, comment)

        return Line(line, LineType.CODE, line, "")

    def transform_alias_to_multiline_function(self, line: str) -> str:
        """
        Convert alias to a multiline function while preserving quotes.
        
        :param line: Line to transform
        :return: Transformed line
        """
        match = re.match(r'''alias\s+([a-zA-Z0-9_-]+)\s*=\s*['"](.*)['"]$''', line.strip())
        if not match:
            return line
        alias_name, command_part = match.groups()
        
        return f'function {alias_name} {{\n {command_part}\n}}\n'

    def transform_singleline_to_multiline_function(self, line: str) -> str:
        """
        Convert single-line functions into properly formatted multiline functions.
        
        :param line: Line to transform
        :return: Transformed line
        """
        match = re.match(r'''(?:function\s+)?([a-zA-Z0-9_-]+)\s*\(\)\s*\{(.*)\}$''', line.strip())
        if not match:
            return line

        func_name, body = match.groups()
        parts = self.split_commands_preserve_args(body)
        
        indented_body = '\n    '.join(parts)
        
        return f"function {func_name}() {{\n\t{indented_body}\n}}\n"

    def split_commands_preserve_args(self, command_string: str) -> List[str]:
        """
        Split commands while preserving quotes and nested structures.
        
        :param command_string: String of commands to split
        :return: List of split commands
        """
        parts = []
        current = []
        in_quotes = False
        quote_char = None
        escaped = False
        brace_level = 0
        paren_level = 0

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

    def process(self) -> int:
        """
        Process the bash file to transform aliases and functions.
        
        :return: Exit code (0 for success, 1 for error)
        """
        try:
            with open(self.input_path, 'r') as f:
                lines = f.readlines()

            block_level = 0

            for line in lines:
                analyzed = self.analyze_line(line)

                # Handle block start and end
                if analyzed.line_type in {LineType.BLOCK_START, LineType.BLOCK_END}:
                    self.processed_lines.append(line)
                    continue

                # If inside a block, keep line as-is
                if block_level > 0:
                    self.processed_lines.append(line)
                    continue

                # Process code lines
                if analyzed.line_type == LineType.CODE:
                    transformed = self.transform_alias_to_multiline_function(line)
                    if transformed == line:
                        transformed = self.transform_singleline_to_multiline_function(transformed)
                    self.processed_lines.append(transformed)

                elif analyzed.line_type == LineType.MIXED:
                    transformed = self.transform_alias_to_multiline_function(analyzed.code_part)
                    if transformed == analyzed.code_part:
                        transformed = self.transform_singleline_to_multiline_function(transformed)

                    if transformed != analyzed.code_part:
                        transformed = transformed.rstrip('\n') + ' ' + analyzed.comment_part + '\n'
                    else:
                        transformed = line
                    
                    self.processed_lines.append(transformed)

                else:
                    self.processed_lines.append(line)

            result = ''.join(self.processed_lines)

            if self.output_path:
                with open(self.output_path, 'w') as f:
                    f.write(result)
                print(f"Transformed bash script written to {self.output_path}")
            else:
                print(result, end='')

        except Exception as e:
            print(f"Error processing bash file {self.input_path}: {str(e)}", file=sys.stderr)
            return 1

        return 0

def main():
    """Main entry point for the script."""
    parser = argparse.ArgumentParser(description='Transform bash aliases and single-line functions to multiline format')
    
    parser.add_argument('input_file', help='Input bash file to transform')
    parser.add_argument('-o', '--output', help='Output file (if not specified, prints to stdout)')

    args = parser.parse_args()
    
    input_path = Path(args.input_file)
    output_path = Path(args.output) if args.output else None

    if not input_path.exists():
        print(f"Error: Input file {input_path} does not exist", file=sys.stderr)
        return 1

    transformer = BashTransformer(input_path, output_path)
    return transformer.process()

if __name__ == '__main__':
    sys.exit(main())