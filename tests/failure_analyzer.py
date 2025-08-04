#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# failure_analyzer.py: Analyzes BATS++ test failures to identify suspect commands.
#
# This script processes test output directories to find failed test cases,
# extracts the commands responsible for the failures, and generates both a
# human-readable summary and a machine-readable JSON report. It uses multiple
# strategies to pinpoint failing commands from generated shell scripts and trace files.
#
## TODO: Replace standard I/O operations with mezcla methods

"""
Analyzes BATS++ test failures to identify and rank suspect commands.

Parses a directory of test results (*.outputpp.out), finds all 'not ok'
tests, and correlates them with the commands that were executed. It then
aggregates this data to produce a summary of the most frequent failures.

Sample usage:
   {script} /path/to/test/results/directory --json-filename report.json
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

    def setup(self):
        """Check results of command line processing and initialize members."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        
        # FIX: The 'mezcla' framework has a quirk. Even for positional arguments,
        # we must use get_parsed_option() to avoid disrupting the run loop.
        # The debug log's "FYI" message pointed to this solution.
        self.results_dir = self.get_parsed_option(RESULTS_DIR)
        
        self.json_filename = self.get_parsed_option(JSON_FILENAME, self.json_filename)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def _find_failed_tests(self, output_file_path: Path) -> list[str]:
        """Parses a .outputpp.out file for "not ok ..." lines."""
        failed_tests = []
        failure_pattern = r"^\s*not ok\s+\d+\s+(test-\d+)\s*$"
        try:
            with open(output_file_path, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    match = my_re.search(failure_pattern, line)
                    if match:
                        failed_tests.append(match.group(1))
        except FileNotFoundError:
            return []
        return failed_tests

    def _extract_from_generated_script(self, script_path: Path, test_name: str) -> str | None:
        """Strategy 1: Extracts suspect using a robust line-based state machine."""
        if not script_path.exists():
            return None
    
        in_target_function = False
        function_body_lines = []
    
        start_pattern = rf"^\s*function\s+{test_name}-actual\s*\(\)\s*{{"
        end_pattern = r"^\s*}\s*$"

        try:
            with open(script_path, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    if in_target_function:
                        if my_re.search(end_pattern, line):
                            break
                        function_body_lines.append(line)
                    elif my_re.search(start_pattern, line):
                        in_target_function = True
        
            if not function_body_lines:
                return None

            cleaned_lines = [
                line.strip() for line in function_body_lines
                if line.strip() and not line.strip().startswith('#') and line.strip() != 'true'
            ]
            return "\n".join(cleaned_lines) if cleaned_lines else None
        except (OSError, UnicodeDecodeError) as e:
            debug.trace(TL.WARNING, f"Failed to process {script_path}: {str(e)}")
            return None

    def _extract_from_trace_file(self, trace_file_path: Path, test_name: str) -> str | None:
        """Strategy 2: Extracts suspect from a simple trace file by command index."""
        try:
            test_number = int(test_name.split('-')[1])
        except (ValueError, IndexError):
            return None

        commands = []
        try:
            with open(trace_file_path, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    if line.strip().startswith('$ '):
                        commands.append(line.strip()[2:].strip())
        except FileNotFoundError:
            return None

        command_index = test_number - 1
        return commands[command_index] if 0 <= command_index < len(commands) else None

    def _analyze_test_run(self) -> list:
        """Orchestrates analysis, tagging each failure with its source file."""
        aggregated_failures = defaultdict(lambda: {'sources': set(), 'count': 0})
        root_path = Path(self.results_dir)

        print("--- Audit Trail: Processing Failure Logs ---")
        files_with_failures = 0
        for output_file in sorted(root_path.rglob('*.bats.outputpp.out')):
            failed_tests = self._find_failed_tests(output_file)
        
            if failed_tests:
                files_with_failures += 1
                source_filename = output_file.name.replace('.bats.outputpp.out', '.batspp')
                print(f"  -> Analyzing {len(failed_tests)} failure(s) in: {source_filename}")

                base_name = output_file.name.replace('.bats.outputpp.out', '')
                generated_script_path = output_file.with_name(f"{base_name}.bats.outputpp")
                trace_file_path = output_file.with_name(f"{base_name}.batspp")

                for test_name in failed_tests:
                    suspect = self._extract_from_generated_script(generated_script_path, test_name)
                    if not suspect:
                        suspect = self._extract_from_trace_file(trace_file_path, test_name)

                    if suspect:
                        aggregated_failures[suspect]['sources'].add(source_filename)
                        aggregated_failures[suspect]['count'] += 1
                    else:
                        debug.trace(TL.WARNING, f"NOTICE: Could not extract suspect for {test_name}")
    
        if files_with_failures == 0:
            print("No files containing failures ('not ok') were found.")
    
        print("-" * 42)

        sorted_failures = sorted(
            aggregated_failures.items(),
            key=lambda item: item[1]['count'],
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
                "count": data['count'],
                "source_files": sorted(list(data['sources'])),
                "suspect_command": command
            })
    
        try:
            with open(self.json_filename, 'w', encoding='utf-8') as f:
                json.dump(report_data, f, indent=4)
            print("JSON report generated successfully.")
        except IOError as e:
            debug.trace(TL.ERROR, f"Error writing JSON file: {e}")

    def run_main_step(self):
        """Main processing step for the script."""
        debug.trace(5, f"Script.run_main_step(): self={self}")
        
        print(f"Executing v11 analysis on target directory: {self.results_dir}\n")
        sorted_failures = self._analyze_test_run()

        if not sorted_failures:
            print("\nAnalysis complete. No failures to report.")
            return

        # Write the full data to JSON
        self._write_json_report(sorted_failures)

        # --- Adaptive Grid Reporting Module ---
        print("\n--- Top 20 Failure Summary (Adaptive Grid) ---")
        headers = ['Rank', 'Count', 'Source(s)', 'Suspect Command(s)']
        table_data = []
        for i, (command, data) in enumerate(sorted_failures[:20], 1):
            sources_cell_content = "\n".join(sorted(list(data['sources'])))
            command_cell_content = command
            table_data.append([i, data['count'], sources_cell_content, command_cell_content])
    
        # Use 'grid' format which handles multi-line cell content gracefully
        print(tabulate(table_data, headers=headers, tablefmt="grid"))


def main():
    """Entry point"""
    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        # This script takes a directory argument and does not process stdin
        manual_input=True,  # Changed from skip_input=True
        # Shows brief usage if no arguments given
        auto_help=True,
        # Define positional arguments and options
        positional_arguments=[(RESULTS_DIR, "Path to the test results directory")],
        text_options=[(JSON_FILENAME, "Output filename for the JSON report")],
    )
    app.run()
    debug.assertion(not any(my_re.search(r"^TODO_", m, my_re.IGNORECASE)
                            for m in dir(app)))

# -------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()