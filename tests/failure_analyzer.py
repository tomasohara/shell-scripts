#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# failure_analyzer.py: Analyzes BATS++ test failures to identify suspect commands.
#
# v16-unified: Handles cross-platform differences in test/function naming (e.g., test-1 vs test_1)
#
## TODO: Replace standard I/O operations with mezcla methods

"""
Analyzes BATS++ test failures to identify and rank suspect commands.

Parses a directory of test results (*.outputpp.out), finds all 'not ok'
tests, and correlates them with the commands that were executed. It then
aggregates this data to produce a summary of the most frequent failures.

Sample usage:
   {script} /path/to/test/results/directory --json-filename report.json
   {script} --results-dir /path/to/test/results/directory
"""

# Standard modules
import json
import sys
from collections import defaultdict
from pathlib import Path

# Installed modules
try:
    from tabulate import tabulate
except ImportError:
    # The Main class will print a more user-friendly error and exit.
    print("Error: The 'tabulate' library is required. Please run 'pip install tabulate'.", file=sys.stderr)
    sys.exit(1)


# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re

# Constants for switches omitting leading dashes
RESULTS_DIR = "results-dir"
JSON_FILENAME = "json-filename"
DIAGNOSTIC_MODE = "diagnostic"

# Constants
TL = debug.TL


class Script(Main):
    """
    Input processing and failure analysis class.
    This script operates in a single run, not on line-by-line input,
    so the main logic resides in run_main_step().
    """
    # Class-level member variables for arguments
    results_dir = "."
    json_filename = "failure_report.json"
    diagnostic_mode = False

    def setup(self):
        """Check results of command line processing and initialize members."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        
        self.results_dir = self._get_results_directory()
        self.json_filename = self.get_parsed_option(JSON_FILENAME, self.json_filename)
        self.diagnostic_mode = self.get_parsed_option(DIAGNOSTIC_MODE, self.diagnostic_mode)
        
        if self.results_dir is None:
            debug.trace(TL.ERROR, "Results directory is None after parsing, defaulting to '.'")
            print("Warning: Could not determine results directory from arguments, using current directory.", 
                  file=sys.stderr)
            self.results_dir = "."

        self.results_dir = self._normalize_path(self.results_dir)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def _get_results_directory(self):
        """
        Safely extract results directory from either positional or named arguments.
        This handles the cross-platform compatibility issue between WSL and Cygwin.
        """
        results_dir = self.get_parsed_option(RESULTS_DIR, None)
        
        if results_dir is None and hasattr(self, 'parsed_args') and isinstance(self.parsed_args, dict):
            if self.parsed_args.get('results-dir') and self.parsed_args['results-dir'] != '-':
                results_dir = self.parsed_args['results-dir']
            elif self.parsed_args.get('_') and self.parsed_args['_'] != '-':
                if isinstance(self.parsed_args['_'], list) and len(self.parsed_args['_']) > 0:
                    results_dir = self.parsed_args['_'][0]
                else:
                    results_dir = self.parsed_args['_']

        if results_dir is None:
            debug.trace(TL.WARNING, "No results directory specified via arguments, defaulting to '.'")
            results_dir = "."
        
        return results_dir

    def _normalize_path(self, path_str: str) -> str:
        """
        Normalize path for cross-platform compatibility and validate existence.
        """
        if not path_str:
            path_str = "."
        try:
            path_obj = Path(path_str).resolve()
        except (OSError, RuntimeError) as e:
            debug.trace(TL.WARNING, f"Could not resolve path {path_str}, using as-is. Error: {e}")
            path_obj = Path(path_str)

        if not path_obj.exists():
            print(f"Error: Directory '{path_obj}' does not exist.", file=sys.stderr)
            sys.exit(1)
        elif not path_obj.is_dir():
            print(f"Error: Path '{path_obj}' is not a directory.", file=sys.stderr)
            sys.exit(1)
        
        return str(path_obj)

    def _find_failed_tests(self, output_file_path: Path) -> list[str]:
        """
        Parses a .outputpp.out file for "not ok ..." lines.
        This regex is now more flexible to handle different BATS output formats.
        """
        failed_tests = []
        # This pattern matches "not ok", the test number, an optional hyphen, and captures the rest.
        pattern = r"^\s*not ok\s+\d+\s+-?\s*(.+)$"
        
        try:
            with open(output_file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            matches = my_re.findall(pattern, content, my_re.MULTILINE)
            if matches:
                # Clean up whitespace and remove potential BATS comments
                failed_tests.extend([m.strip().split('#')[0].strip() for m in matches])
            
            if not failed_tests:
                debug.trace(TL.DETAILED, f"No 'not ok' lines found in {output_file_path.name}")

        except (IOError, UnicodeDecodeError) as e:
            debug.trace(TL.ERROR, f"Error reading file {output_file_path}: {e}")
        
        return list(set(failed_tests))

    def _extract_from_generated_script(self, script_path: Path, test_name: str) -> str | None:
        """
        Extracts suspect command from the generated script.
        This now handles function names like 'test-1-actual' or 'test_1_actual'.
        """
        if not script_path.exists():
            return None
        
        in_target_function = False
        function_body_lines = []
        
        # Sanitize test_name for regex. BATS often replaces spaces with underscores.
        sanitized_test_name = my_re.escape(test_name.replace(' ', '_'))
        
        # Match either '-' or '_' as the separator before 'actual'.
        start_pattern = rf"^\s*(?:function\s+)?{sanitized_test_name}[-_]actual\s*\(\)\s*{{?"
        end_pattern = r"^\s*}}?\s*$"

        try:
            with open(script_path, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    if in_target_function:
                        if my_re.search(end_pattern, line):
                            break
                        function_body_lines.append(line)
                    elif my_re.search(start_pattern, line):
                        in_target_function = True
        
            if not in_target_function:
                debug.trace(TL.WARNING, 
                          f"Could not find function start for '{test_name}' using pattern: {start_pattern}")
                return None

            cleaned_lines = [
                line.strip() for line in function_body_lines
                if line.strip() and not line.strip().startswith(('#', 'true', '}'))
            ]
            return "\n".join(cleaned_lines) if cleaned_lines else None
            
        except (IOError, UnicodeDecodeError) as e:
            debug.trace(TL.WARNING, f"Failed to process {script_path}: {str(e)}")
            return None

    def _find_output_files(self, root_path: Path) -> list[Path]:
        """Find all BATS++ output files (*.outputpp.out)."""
        return sorted(list(root_path.rglob('*.outputpp.out')))

    def _analyze_test_run(self) -> list:
        """Orchestrates analysis, tagging each failure with its source file."""
        aggregated_failures = defaultdict(lambda: {'sources': set(), 'count': 0})
        root_path = Path(self.results_dir)

        print("--- Audit Trail: Processing Failure Logs ---")
        output_files = self._find_output_files(root_path)
        
        if not output_files:
            print(f"No output files (*.outputpp.out) found in directory: {self.results_dir}")
            return []

        for output_file in output_files:
            failed_tests = self._find_failed_tests(output_file)
            if not failed_tests:
                continue

            # Construct source/generated filenames robustly
            base_name = output_file.name.replace('.outputpp.out', '')
            source_filename = f"{base_name}.batspp"
            generated_script_path = output_file.with_name(f"{base_name}.outputpp")
            
            print(f"  -> Analyzing {len(failed_tests)} failure(s) in: {source_filename}")

            for test_name in failed_tests:
                suspect = self._extract_from_generated_script(generated_script_path, test_name)
                if suspect:
                    aggregated_failures[suspect]['sources'].add(source_filename)
                    aggregated_failures[suspect]['count'] += 1
                else:
                    debug.trace(TL.WARNING, 
                               f"NOTICE: Could not extract suspect for '{test_name}' from {generated_script_path.name}")
        
        print("-" * 42)

        if not aggregated_failures:
            return []

        for data in aggregated_failures.values():
            data['impact'] = data['count'] * len(data['sources'])

        sorted_failures = sorted(
            aggregated_failures.items(),
            key=lambda item: item[1]['impact'],
            reverse=True
        )
        return sorted_failures

    def _write_json_report(self, sorted_failures: list):
        """Writes the complete, attributed failure data to a JSON file."""
        print(f"\nWriting full report to {self.json_filename}...")
        report_data = []
        for i, (command, data) in enumerate(sorted_failures, 1):
            report_data.append({
                "rank": i,
                "impact_score": data['impact'],
                "failure_count": data['count'],
                "affected_files": len(data['sources']),
                "source_files": sorted(list(data['sources'])),
                "suspect_command": command
            })
        try:
            with open(self.json_filename, 'w', encoding='utf-8') as f:
                json.dump(report_data, f, indent=2)
            print("JSON report generated successfully.")
        except IOError as e:
            print(f"Error: Could not write JSON report to {self.json_filename}: {e}")

    def run_main_step(self):
        """Main processing step for the script."""
        version = "v16-unified"
        print(f"Executing {version} analysis on target directory: {self.results_dir}\n")
        
        sorted_failures = self._analyze_test_run()

        if not sorted_failures:
            print("\nAnalysis complete. No actionable failures were extracted.")
            return

        self._write_json_report(sorted_failures)

        print("\n--- Top 20 Failure Summary (Sorted by Impact) ---")
        headers = ['Rank', 'Impact', 'Count', 'Files', 'Suspect Command(s)']
        table_data = []
        for i, (command, data) in enumerate(sorted_failures[:20], 1):
            table_data.append([i, data['impact'], data['count'], len(data['sources']), command])
    
        print(tabulate(table_data, headers=headers, tablefmt="grid", maxcolwidths=[None, None, None, None, 70]))

def main():
    """Entry point"""
    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        manual_input=True,
        auto_help=True,
        boolean_options=[(DIAGNOSTIC_MODE, "Enable diagnostic mode to analyze file content")],
        text_options=[
            (RESULTS_DIR, "Path to the test results directory"),
            (JSON_FILENAME, "Output filename for the JSON report")
        ],
        positional_options=[(RESULTS_DIR, "Path to the test results directory")]
    )
    app.run()

if __name__ == '__main__':
    main()
