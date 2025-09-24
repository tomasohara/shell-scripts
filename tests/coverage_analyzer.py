#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# coverage_analyzer.py: Analyzes kcov output to determine per-macro test coverage.

import json
import os
import re
import argparse
from collections import defaultdict

def parse_macro_locations(source_dir: str) -> dict:
    """
    Parses all .bash files in a directory to find macro definitions and their line numbers.

    Returns:
        A dictionary mapping macro names to their location info.
        Example: {'run-python-script': {'file': 'path/to/file.bash', 'start': 10, 'end': 50}}
    """
    macros = {}
    # Regex to find function definitions. This might need to be adjusted for aliases.
    # It looks for `function name {` or `name() {`.
    func_pattern = re.compile(r"^(?:function\s+)?([\w-]+)\s*\(\)\s*\{")

    for filename in os.listdir(source_dir):
        if not filename.endswith(".bash"):
            continue

        file_path = os.path.join(source_dir, filename)
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()

        active_function_name = None
        brace_count = 0
        start_line = 0

        for i, line in enumerate(lines, 1):
            if active_function_name is None:
                match = func_pattern.match(line.strip())
                if match:
                    active_function_name = match.group(1)
                    start_line = i
                    brace_count = 1
            elif '{' in line:
                brace_count += line.count('{')
            
            if '}' in line:
                brace_count -= line.count('}')

            if active_function_name and brace_count == 0:
                macros[active_function_name] = {
                    "file": file_path,
                    "start": start_line,
                    "end": i
                }
                active_function_name = None

    print(f"Found {len(macros)} macro definitions.")
    return macros

def load_kcov_data(kcov_json_path: str) -> dict:
    """Loads the detailed line-by-line coverage data from kcov's JSON file."""
    print(f"Loading kcov data from: {kcov_json_path}")
    with open(kcov_json_path, 'r') as f:
        # TODO: The structure of kcov's internal JSON can vary. You may need to inspect
        # your `coverage.json` file and adjust the keys here.
        # This assumes a structure like: {"files": [{"file": "path", "lines": [...]}]}
        return json.load(f)

def calculate_macro_coverage(macros: dict, kcov_data: dict) -> list:
    """
    Calculates coverage for each macro using the kcov line-by-line data.
    """
    report = []
    
    # Create a more efficient lookup table for kcov data
    kcov_file_map = {item['file']: item for item in kcov_data.get('files', [])}

    for name, loc in macros.items():
        file_path = loc['file']
        
        if file_path not in kcov_file_map:
            continue # This source file was not touched by any tests

        # TODO: Adjust the keys based on your kcov JSON structure.
        # This assumes each file object has a "lines" key with a list of line objects.
        # Each line object might look like: {"line_number": X, "execution_count": Y}
        lines_data = kcov_file_map[file_path].get('lines', [])
        
        total_lines = 0
        covered_lines = 0
        
        for line_info in lines_data:
            line_num = line_info.get('line_number')
            exec_count = line_info.get('execution_count')
            
            # Check if this line is within the current macro's body
            if loc['start'] <= line_num <= loc['end']:
                total_lines += 1
                if exec_count > 0:
                    covered_lines += 1

        if total_lines > 0:
            percent_covered = (covered_lines / total_lines) * 100
        else:
            # Handle empty functions or parsing errors
            percent_covered = 0.0

        status = "untested"
        if covered_lines > 0:
            status = "insufficiently_tested" if percent_covered < 80.0 else "well_tested"

        report.append({
            "macro": name,
            "file": file_path,
            "percent_covered": round(percent_covered, 2),
            "covered_lines": covered_lines,
            "total_lines": total_lines,
            "status": status
        })

    # Sort by percentage, lowest first
    return sorted(report, key=lambda x: x['percent_covered'])


def main():
    """Main function to orchestrate the analysis."""
    parser = argparse.ArgumentParser(description="Analyze kcov output for per-macro coverage.")
    parser.add_argument('--kcov-json', required=True, help="Path to the detailed coverage.json from kcov's merged report.")
    parser.add_argument('--source-dir', required=True, help="Path to the directory with .bash macro definition files.")
    parser.add_argument('--output-file', default='macro_coverage_report.json', help="Name of the output JSON report file.")
    args = parser.parse_args()

    # Step 1: Find where all macros are defined
    macro_locations = parse_macro_locations(args.source_dir)
    
    # Step 2: Load the detailed coverage data
    kcov_coverage_data = load_kcov_data(args.kcov_json)

    # Step 3: Calculate coverage for each macro
    final_report = calculate_macro_coverage(macro_locations, kcov_coverage_data)

    # Step 4: Write the final report
    with open(args.output_file, 'w') as f:
        json.dump(final_report, f, indent=2)
    
    print(f"\nAnalysis complete. Report saved to: {args.output_file}")


if __name__ == '__main__':
    main()
    