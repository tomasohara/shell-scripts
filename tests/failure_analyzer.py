#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# failure_analyzer.py: Analyzes BATS++ test failures to identify suspect commands.
#
# v18-addon.10: Simplified Script class and path handling for better clarity.
# v18-addon.9: Modified heuristic sort order to prioritize failure count over percentage.
# v18-addon.8: Refactored core logic into helper functions for testability.
# v18-addon.7: Fixes pylint style issues.
#
## TODO: Create test_failure_analyzer.py to test the new heuristic logic.

"""
Analyzes BATS++ test failures to identify and rank suspect commands.

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
# Helper functions (API) for testability, separating logic from the CLI.
# ------------------------------------------------------------------------------

def _find_output_files(root_dir: str) -> list[Path]:
    """Find all BATS++ output files (*.outputpp.out)."""
    root_path = Path(root_dir)
    return sorted(list(root_path.rglob('*.outputpp.out')))

def _find_failed_tests(output_file_path: Path) -> list[str]:
    """Parses a .outputpp.out file for "not ok ..." lines."""
    pattern = r"^\s*not ok\s+\d+\s+-?\s*(.+)$"
    try:
        content = output_file_path.read_text(encoding='utf-8', errors='ignore')
        matches = my_re.findall(pattern, content, my_re.MULTILINE)
        return list({m.strip().split('#')[0].strip() for m in matches}) if matches else []
    except (IOError, UnicodeDecodeError) as e:
        debug.trace(TL.ERROR, f"Error reading file {output_file_path}: {e}")
        return []

def _extract_from_generated_script(script_path: Path, test_name: str) -> str | None:
    """Extracts suspect command from the generated script."""
    ## ADDON: Simplified function body extraction using a single regex search.
    ## This avoids line-by-line iteration and state flags (in_target_function).
    if not script_path.exists():
        return None
    try:
        content = script_path.read_text(encoding='utf-8', errors='ignore')
        sanitized_test_name = my_re.escape(test_name.replace(' ', '_'))
        # This regex finds the function and captures the content between the first '{' and last '}'
        pattern = rf"^\s*(?:function\s+)?{sanitized_test_name}[-_]actual\s*\(\)\s*{{((?:.|\n)*?)^\s*}}?\s*$"
        match = my_re.search(pattern, content, my_re.MULTILINE)
        if not match:
            return None
        
        function_body = match.group(1)
        cleaned_lines = [l.strip() for l in function_body.splitlines() if l.strip() and not l.strip().startswith(('#', 'true', '}'))]
        return "\n".join(cleaned_lines) if cleaned_lines else None
    except (IOError, UnicodeDecodeError) as e:
        debug.trace(TL.WARNING, f"Failed to process {script_path}: {str(e)}")
        return None

def analyze_test_run(results_dir: str) -> list:
    """Orchestrates the original analysis, blaming test blocks."""
    aggregated_failures = defaultdict(lambda: {'sources': set(), 'count': 0})
    print("--- Audit Trail: Processing Failure Logs (Original Mode) ---")
    output_files = _find_output_files(results_dir)

    if not output_files:
        print(f"No output files (*.outputpp.out) found in directory: {results_dir}")
        return []
    for output_file in output_files:
        failed_tests = _find_failed_tests(output_file)
        if not failed_tests:
            continue
        base_name = output_file.name.replace('.outputpp.out', '')
        source_filename = f"{base_name}.batspp"
        generated_script_path = output_file.with_name(f"{base_name}.outputpp")
        print(f"  -> Analyzing {len(failed_tests)} failure(s) in: {source_filename}")
        for test_name in failed_tests:
            suspect = _extract_from_generated_script(generated_script_path, test_name)
            if suspect:
                aggregated_failures[suspect]['sources'].add(source_filename)
                aggregated_failures[suspect]['count'] += 1
    print("-" * 54)
    if not aggregated_failures:
        return []
    for data in aggregated_failures.values():
        data['impact'] = data['count'] * len(data['sources'])
    return sorted(aggregated_failures.items(), key=lambda item: item[1]['impact'], reverse=True)

def analyze_macro_failures(results_dir: str) -> list:
    """
    Estimates which macros/functions are failing the most and in which files.
    """
    print("--- Running Macro Failure Heuristic Analysis ---")
    try:
        raw_macros_output = gh.run("bash -c -i 'show-macros-proper'").splitlines()
    except SystemError as e:
        system.exit(f"Error: Could not execute 'show-macros-proper'. Is it in your PATH? Details: {e}", status_code=1)

    ## ADDON: Simplified macro list generation using a set comprehension.
    macros = {
        my_re.sub(r'\s*\(\)\s*$', '', my_re.sub(r'^\s*function\s+', '', line.strip())).strip()
        for line in raw_macros_output
        if line.strip() and my_re.match(r'^[a-zA-Z0-9_:-]+$', my_re.sub(r'\s*\(\)\s*$', '', my_re.sub(r'^\s*function\s+', '', line.strip())).strip())
    }

    if not macros:
        system.exit("Error: 'show-macros-proper' returned no valid macros after sanitization.", status_code=1)

    debug.trace(TL.DETAILED, f"Sanitized macro list contains {len(macros)} items. Example: {list(macros)[:5]}")

    macro_stats = defaultdict(lambda: {'total': 0, 'bad': 0, 'bad_files': set()})
    output_files = _find_output_files(results_dir)
    if not output_files:
        print(f"No output files (*.outputpp.out) found in directory: {results_dir}")
        return []

    for output_file in output_files:
        base_name = output_file.name.replace('.outputpp.out', '')
        source_filename = f"{base_name}.batspp"
        try:
            content = output_file.read_text(encoding='utf-8', errors='ignore')
            snippets = my_re.split(r'\n(?:# Toplevel|={10,})\n', content)

            for snippet in snippets:
                if not snippet.strip() or not snippet.strip().startswith(('ok', 'not ok')):
                    continue
                is_bad_snippet = snippet.strip().startswith("not ok")
                for macro in macros:
                    if my_re.search(rf'\b{my_re.escape(macro)}\b', snippet):
                        macro_stats[macro]['total'] += 1
                        if is_bad_snippet:
                            macro_stats[macro]['bad'] += 1
                            macro_stats[macro]['bad_files'].add(source_filename)
        except IOError as e:
            debug.trace(TL.ERROR, f"Could not read {output_file}: {e}")

    results = []
    for macro, stats in macro_stats.items():
        if stats['total'] > 0:
            pct_bad = (stats['bad'] / stats['total']) * 100
            results.append({
                "macro": macro, "bad": stats['bad'], "total": stats['total'],
                "pct_bad": pct_bad, "failing_in_files": sorted(list(stats['bad_files']))
            })
    return sorted(results, key=lambda x: (x['bad'], x['pct_bad']), reverse=True)


class Script(Main):
    """
    Input processing and failure analysis class.
    """
    results_dir = "."
    json_filename = None
    diagnostic_mode = False
    heuristic_mode = False

    def setup(self):
        """Check results of command line processing and initialize members."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        super().setup()

        ## ADDON: Simplified path retrieval and validation.
        # This removes the need for _get_results_directory and _normalize_path helpers.
        path_str = self.get_parsed_option(RESULTS_DIR, ".")
        try:
            results_path = Path(path_str).resolve(strict=True)
            if not results_path.is_dir():
                system.exit(f"Error: Path '{results_path}' is not a directory.", status_code=1)
            self.results_dir = str(results_path)
        except FileNotFoundError:
            system.exit(f"Error: Directory '{path_str}' does not exist.", status_code=1)
        except IOError as e:
            system.exit(f"Error processing path '{path_str}': {e}", status_code=1)

        self.diagnostic_mode = self.get_parsed_option(DIAGNOSTIC_MODE, self.diagnostic_mode)
        self.heuristic_mode = self.get_parsed_option(HEURISTIC_MODE, self.heuristic_mode)

        user_provided_filename = self.get_parsed_option(JSON_FILENAME, None)
        if user_provided_filename:
            self.json_filename = user_provided_filename
        elif self.heuristic_mode:
            self.json_filename = "failure_analyzer_heuristic.json"
        else:
            self.json_filename = "failure_analyzer_report.json"

        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    ## ADDON: Removed redundant wrapper methods (_find_output_files, _find_failed_tests,
    ## _extract_from_generated_script, _analyze_test_run, _analyze_macro_failures,
    ## _get_results_directory, _normalize_path). The main run step now calls the
    ## standalone helper functions directly, simplifying the class.

    def _write_json_report(self, report_data: list, is_heuristic: bool):
        """Writes the analysis data to a JSON file."""
        print(f"\nWriting full report to {self.json_filename}...")

        if not is_heuristic:
            ## ADDON: Converted report generation to a more concise list comprehension.
            output_data = [
                {
                    "rank": i, "impact_score": data['impact'], "failure_count": data['count'],
                    "affected_files": len(data['sources']), "source_files": sorted(list(data['sources'])),
                    "suspect_command": command
                }
                for i, (command, data) in enumerate(report_data, 1)
            ]
        else:
            output_data = report_data

        try:
            with open(self.json_filename, 'w', encoding='utf-8') as f:
                json.dump(output_data, f, indent=2)
            print("JSON report generated successfully.")
        except IOError as e:
            system.exit(f"Error: Could not write JSON report to {self.json_filename}: {e}", status_code=1)

    def run_main_step(self):
        """
        Main processing step for the script.
        """
        ## ADDON: Updated version string.
        version = "v18-addon.10"
        print(f"Executing {version} analysis on target directory: {self.results_dir}\n")

        if self.heuristic_mode:
            ## ADDON: Call the standalone helper function directly.
            sorted_macro_failures = analyze_macro_failures(self.results_dir)
            if not sorted_macro_failures:
                print("\nAnalysis complete. No macro usage was found in test outputs.")
                return
            self._write_json_report(sorted_macro_failures, is_heuristic=True)

            print("\n--- Top 20 Suspect Macros/Functions (Sorted by Failure Count) ---")
            headers = ['Rank', 'Macro/Function', 'Bad Hits', 'Total Uses', 'Failure Rate', 'Failing In']
            table_data = []
            for i, data in enumerate(sorted_macro_failures[:20], 1):
                rate_str = f"{data['pct_bad']:.1f}%"
                failing_files = data['failing_in_files']
                files_str = ""
                if failing_files:
                    files_to_show = failing_files[:3]
                    files_str = "\n".join(files_to_show)
                    if len(failing_files) > 3:
                        files_str += f"\n(...and {len(failing_files) - 3} more)"
                table_data.append([i, data['macro'], data['bad'], data['total'], rate_str, files_str])
            print(tabulate(table_data, headers=headers, tablefmt="fancy_grid", maxcolwidths=[None, None, None, None, None, 45]))
        else:
            ## ADDON: Call the standalone helper function directly.
            sorted_failures = analyze_test_run(self.results_dir)
            if not sorted_failures:
                print("\nAnalysis complete. No actionable failures were extracted.")
                return
            self._write_json_report(sorted_failures, is_heuristic=False)
            print("\n--- Top 20 Failure Summary (Sorted by Impact) ---")
            headers = ['Rank', 'Impact', 'Count', 'Files', 'Suspect Command(s)']
            table_data = []
            for i, (command, data) in enumerate(sorted_failures[:20], 1):
                table_data.append([i, data['impact'], data['count'], len(data['sources']), command])
            print(tabulate(table_data, headers=headers, tablefmt="fancy_grid", maxcolwidths=[None, None, None, None, 70]))

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
