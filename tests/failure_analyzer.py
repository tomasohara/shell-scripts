#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# failure_analyzer.py: Analyzes BATS++ test failures to identify suspect commands.
#
# v18-addon.20: Added check=True to gh.run to ensure it fails on non-zero exit codes.
# v18-addon.19: Broadened exception handling for gh.run to catch any subprocess failure.
# v18-addon.18: REMOVED '-i' flag from gh.run to prevent interactive shell from overwriting PATH.
# v18-addon.17: Refactored to fully align with the 'mezcla' two-class template.
#
## TODO: Create test_failure_analyzer.py to test the new heuristic logic.

"""
Analyzes BATSPP test failures to identify and rank suspect commands.

This script offers two modes of analysis:
1. Default Mode: Identifies failing test code blocks.
2. Heuristic Mode (--heuristic): Estimates the failure probability for each Bash macro/function
   and lists the files where failures occur directly in the console output.

Sample usage:
   # Original analysis (blames code blocks) -> outputs failure_analyzer_report.json
   {script} /path/to/results

   # New heuristic analysis (blames macros) -> outputs failure_analyzer_heuristic.json
   {script} /path/to/results --heuristic
"""

# Standard modules
import json
import os
from collections import defaultdict
from pathlib import Path

# Local modules
from mezcla import system
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re

# Installed modules
try:
    from tabulate import tabulate
except ImportError:
    system.exit("Error: The 'tabulate' library is required. Please run 'pip install tabulate'.", status_code=1)


# Constants for switches omitting leading dashes
RESULTS_DIR = "results-dir"
JSON_FILENAME = "json-filename"
DIAGNOSTIC_MODE = "diagnostic"
HEURISTIC_MODE = "heuristic"

# Constants
TL = debug.TL

# ------------------------------------------------------------------------------
# Core Logic Class (API)
# ------------------------------------------------------------------------------

class FailureAnalyzer:
    """
    Main logic class for analyzing BATS++ failures. Encapsulates all analysis,
    file processing, and reporting.
    """

    def __init__(self, results_dir: str, is_heuristic: bool, json_filename: str | None = None):
        """Initializes the analyzer with all necessary parameters."""
        self.results_dir = results_dir
        self.is_heuristic = is_heuristic
        self.json_filename = self._resolve_json_filename(json_filename)
        self.report_data = []

    def run(self):
        """
        Main orchestration method. Runs the analysis, writes the report,
        and prints the summary table.
        """
        if self.is_heuristic:
            self.report_data = self._analyze_macro_failures()
        else:
            self.report_data = self._analyze_test_run()

        if not self.report_data:
            if self.is_heuristic:
                print("\nAnalysis complete. No macro usage was found in test outputs.")
            else:
                print("\nAnalysis complete. No actionable failures were extracted.")
            return

        self._write_json_report()
        self._print_summary_table()

    def _resolve_json_filename(self, json_filename: str | None) -> str:
        """Determines the correct output path for the JSON report."""
        if json_filename:
            return json_filename
        default_name = "failure_analyzer_heuristic.json" if self.is_heuristic else "failure_analyzer_report.json"
        return os.path.join(self.results_dir, default_name)

    def _find_output_files(self) -> list[str]:
        """Find all BATS++ output files (*.outputpp.out) recursively."""
        matched_files = []
        dirs_to_visit = [self.results_dir]
        while dirs_to_visit:
            current_dir = dirs_to_visit.pop()
            try:
                for name in system.read_directory(current_dir):
                    full_path = os.path.join(current_dir, name)
                    if system.is_directory(full_path):
                        dirs_to_visit.append(full_path)
                    elif name.endswith('.outputpp.out'):
                        matched_files.append(full_path)
            except IOError as e:
                debug.trace(TL.ERROR, f"Could not process directory {current_dir}: {e}")
        return sorted(matched_files)

    def _find_failed_tests(self, output_file_path: str) -> list[str]:
        """Parses a .outputpp.out file for "not ok ..." lines."""
        pattern = r"^\s*not ok\s+\d+\s+-?\s*(.+)$"
        try:
            content = system.read_file(output_file_path, errors='ignore')
            if not content: return []
            matches = my_re.findall(pattern, content, my_re.MULTILINE)
            return list({m.strip().split('#')[0].strip() for m in matches}) if matches else []
        except IOError as e:
            debug.trace(TL.ERROR, f"Error reading file {output_file_path}: {e}")
            return []

    def _extract_from_generated_script(self, script_path: str, test_name: str) -> str | None:
        """Extracts suspect command from the generated script."""
        if not system.file_exists(script_path): return None
        try:
            content = system.read_file(script_path, errors='ignore')
            if not content: return None
            sanitized_test_name = my_re.escape(test_name.replace(' ', '_'))
            pattern = rf"^\s*(?:function\s+)?{sanitized_test_name}[-_]actual\s*\(\)\s*{{((?:.|\n)*?)^\s*}}?\s*$"
            match = my_re.search(pattern, content, my_re.MULTILINE)
            if not match: return None
            function_body = match.group(1)
            cleaned_lines = [l.strip() for l in function_body.splitlines() if l.strip() and not l.strip().startswith(('#', 'true', '}'))]
            return "\n".join(cleaned_lines) if cleaned_lines else None
        except IOError as e:
            debug.trace(TL.WARNING, f"Failed to process {script_path}: {str(e)}")
            return None

    def _analyze_test_run(self) -> list:
        """Orchestrates the original analysis, blaming test blocks."""
        aggregated_failures = defaultdict(lambda: {'sources': set(), 'count': 0})
        print("--- Audit Trail: Processing Failure Logs (Original Mode) ---")
        output_files = self._find_output_files()
        if not output_files:
            print(f"No output files (*.outputpp.out) found in directory: {self.results_dir}")
            return []
        for output_file_str in output_files:
            output_file = Path(output_file_str)
            failed_tests = self._find_failed_tests(output_file_str)
            if not failed_tests: continue
            base_name = output_file.name.replace('.outputpp.out', '')
            source_filename = f"{base_name}.batspp"
            generated_script_path = str(output_file.with_name(f"{base_name}.outputpp"))
            print(f"  -> Analyzing {len(failed_tests)} failure(s) in: {source_filename}")
            for test_name in failed_tests:
                suspect = self._extract_from_generated_script(generated_script_path, test_name)
                if suspect:
                    aggregated_failures[suspect]['sources'].add(source_filename)
                    aggregated_failures[suspect]['count'] += 1
        print("-" * 54)
        if not aggregated_failures: return []
        for data in aggregated_failures.values():
            data['impact'] = data['count'] * len(data['sources'])
        return sorted(aggregated_failures.items(), key=lambda item: item[1]['impact'], reverse=True)

    def _analyze_macro_failures(self) -> list:
        """Estimates which macros/functions are failing the most."""
        print("--- Running Macro Failure Heuristic Analysis ---")
        try:
            # CRITICAL FIX: Added check=True to force an exception on non-zero exit codes.
            raw_macros_output = gh.run("bash -c 'show-macros-proper'", check=True).splitlines()
        except Exception as e:
            system.exit(f"Error: Could not execute 'show-macros-proper'. Is it in your PATH? Details: {e}", status_code=1)

        macros = {my_re.sub(r'\s*\(\)\s*$', '', my_re.sub(r'^\s*function\s+', '', l.strip())).strip() for l in raw_macros_output if l.strip() and my_re.match(r'^[a-zA-Z0-9_:-]+$', my_re.sub(r'\s*\(\)\s*$', '', my_re.sub(r'^\s*function\s+', '', l.strip())).strip())}
        if not macros:
            system.exit("Error: 'show-macros-proper' returned no valid macros after sanitization.", status_code=1)
        debug.trace(TL.DETAILED, f"Sanitized macro list contains {len(macros)} items. Example: {list(macros)[:5]}")
        macro_stats = defaultdict(lambda: {'total': 0, 'bad': 0, 'bad_files': set()})
        output_files = self._find_output_files()
        if not output_files:
            print(f"No output files (*.outputpp.out) found in directory: {self.results_dir}")
            return []
        for output_file_str in output_files:
            output_file = Path(output_file_str)
            base_name = output_file.name.replace('.outputpp.out', '')
            source_filename = f"{base_name}.batspp"
            try:
                content = system.read_file(output_file_str, errors='ignore')
                if not content: continue
                snippets = my_re.split(r'\n(?:# Toplevel|={10,})\n', content)
                for snippet in snippets:
                    if not snippet.strip() or not snippet.strip().startswith(('ok', 'not ok')): continue
                    is_bad_snippet = snippet.strip().startswith("not ok")
                    for macro in macros:
                        if my_re.search(rf'\b{my_re.escape(macro)}\b', snippet):
                            macro_stats[macro]['total'] += 1
                            if is_bad_snippet:
                                macro_stats[macro]['bad'] += 1
                                macro_stats[macro]['bad_files'].add(source_filename)
            except IOError as e:
                debug.trace(TL.ERROR, f"Could not read {output_file_str}: {e}")
        results = []
        for macro, stats in macro_stats.items():
            if stats['total'] > 0:
                pct_bad = (stats['bad'] / stats['total']) * 100
                results.append({"macro": macro, "bad": stats['bad'], "total": stats['total'], "pct_bad": pct_bad, "failing_in_files": sorted(list(stats['bad_files']))})
        return sorted(results, key=lambda x: (x['bad'], x['pct_bad']), reverse=True)

    def _write_json_report(self):
        """Writes the analysis data to a JSON file."""
        print(f"\nWriting full report to {self.json_filename}...")
        if not self.is_heuristic:
            output_data = [{"rank": i, "impact_score": data['impact'], "failure_count": data['count'], "affected_files": len(data['sources']), "source_files": sorted(list(data['sources'])), "suspect_command": command} for i, (command, data) in enumerate(self.report_data, 1)]
        else:
            output_data = self.report_data
        try:
            json_string = json.dumps(output_data, indent=2)
            system.write_file(self.json_filename, json_string)
            print("JSON report generated successfully.")
        except IOError as e:
            system.exit(f"Error: Could not write JSON report to {self.json_filename}: {e}", status_code=1)

    def _print_summary_table(self):
        """Prints the formatted summary table to the console."""
        if self.is_heuristic:
            print("\n--- Top 20 Suspect Macros/Functions (Sorted by Failure Count) ---")
            headers = ['Rank', 'Macro/Function', 'Bad Hits', 'Total Uses', 'Failure Rate', 'Failing In']
            table_data = []
            for i, data in enumerate(self.report_data[:20], 1):
                rate_str = f"{data['pct_bad']:.1f}%"
                failing_files = data['failing_in_files']
                files_str = ""
                if failing_files:
                    files_to_show = failing_files[:3]
                    files_str = "\n".join(files_to_show)
                    if len(failing_files) > 3: files_str += f"\n(...and {len(failing_files) - 3} more)"
                table_data.append([i, data['macro'], data['bad'], data['total'], rate_str, files_str])
            print(tabulate(table_data, headers=headers, tablefmt="fancy_grid", maxcolwidths=[None, None, None, None, None, 45]))
        else:
            print("\n--- Top 20 Failure Summary (Sorted by Impact) ---")
            headers = ['Rank', 'Impact', 'Count', 'Files', 'Suspect Command(s)']
            table_data = []
            for i, (command, data) in enumerate(self.report_data[:20], 1):
                table_data.append([i, data['impact'], data['count'], len(data['sources']), command])
            print(tabulate(table_data, headers=headers, tablefmt="fancy_grid", maxcolwidths=[None, None, None, None, 70]))

# ------------------------------------------------------------------------------
# Command-Line Interface (CLI) Wrapper
# ------------------------------------------------------------------------------

class Script(Main):
    """
    Input processing, orchestration, and reporting class.
    This class is a thin wrapper around the core FailureAnalyzer logic.
    """
    results_dir = "."
    json_filename = None
    diagnostic_mode = False
    heuristic_mode = False

    def setup(self):
        """Check results of command line processing and initialize members."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        super().setup()

        path_str = self.get_parsed_option(RESULTS_DIR, ".")
        # Use abspath to handle relative paths from CLI subprocesses correctly.
        abs_path_str = os.path.abspath(path_str)

        if not system.file_exists(abs_path_str):
            system.exit(f"Error: Directory '{abs_path_str}' does not exist.", status_code=1)
        if not system.is_directory(abs_path_str):
            system.exit(f"Error: Path '{abs_path_str}' is not a directory.", status_code=1)
        self.results_dir = abs_path_str

        self.diagnostic_mode = self.get_parsed_option(DIAGNOSTIC_MODE, self.diagnostic_mode)
        self.heuristic_mode = self.get_parsed_option(HEURISTIC_MODE, self.heuristic_mode)
        self.json_filename = self.get_parsed_option(JSON_FILENAME, None)

        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def run_main_step(self):
        """
        Main processing step. Instantiates and runs the FailureAnalyzer.
        """
        version = "v18-addon.20"
        print(f"Executing {version} analysis on target directory: {self.results_dir}\n")

        # Instantiate the main logic class with parameters from the CLI.
        analyzer = FailureAnalyzer(
            results_dir=self.results_dir,
            is_heuristic=self.heuristic_mode,
            json_filename=self.json_filename
        )
        
        # Run the full analysis process.
        analyzer.run()

def main():
    """Entry point"""
    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        manual_input=True,
        auto_help=True,
        boolean_options=[
            (DIAGNOSTIC_MODE, "Enable diagnostic mode to analyze file content"),
            (HEURISTIC_MODE, "Use Tom's macro failure heuristic instead of the default analysis")
        ],
        text_options=[
            (RESULTS_DIR, "Path to the test results directory"),
            (JSON_FILENAME, "Output filename for the JSON report (overrides defaults)")
        ],
    )
    app.run()

if __name__ == '__main__':
    main()
