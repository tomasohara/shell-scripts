#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# failure_analyzer.py: Analyzes BATS++ test failures to identify suspect commands.
#
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
# ADDED: Helper functions (API) for testability, separating logic from the CLI.
# These functions are now stateless and can be tested independently.
# ------------------------------------------------------------------------------

def _find_output_files(root_dir: str) -> list[Path]:
    """Find all BATS++ output files (*.outputpp.out)."""
    # KEPT: pathlib is retained here as system.py does not have a recursive glob (`rglob`).
    # This is the most robust way to find all relevant files in subdirectories.
    root_path = Path(root_dir)
    return sorted(list(root_path.rglob('*.outputpp.out')))

def _find_failed_tests(output_file_path: Path) -> list[str]:
    """Parses a .outputpp.out file for "not ok ..." lines."""
    pattern = r"^\s*not ok\s+\d+\s+-?\s*(.+)$"
    try:
        content = output_file_path.read_text(encoding='utf-8', errors='ignore')
        matches = my_re.findall(pattern, content, my_re.MULTILINE)
        # FIX: R1718 (consider-using-set-comprehension)
        return list({m.strip().split('#')[0].strip() for m in matches}) if matches else []
    except (IOError, UnicodeDecodeError) as e:
        debug.trace(TL.ERROR, f"Error reading file {output_file_path}: {e}")
        return []

def _extract_from_generated_script(script_path: Path, test_name: str) -> str | None:
    """Extracts suspect command from the generated script."""
    # KEPT: Using Path object's .exists() method is clean as script_path is already a Path object.
    # FIX: C0321 (multiple-statements)
    if not script_path.exists():
        return None
    in_target_function, function_body_lines = False, []
    sanitized_test_name = my_re.escape(test_name.replace(' ', '_'))
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
        cleaned_lines = [l.strip() for l in function_body_lines if l.strip() and not l.strip().startswith(('#', 'true', '}'))]
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
        # KEPT: .name and .with_name are convenient methods on the Path object.
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

    macros = set()
    for line in raw_macros_output:
        clean_line = my_re.sub(r'^\s*function\s+', '', line.strip())
        clean_line = my_re.sub(r'\s*\(\)\s*$', '', clean_line).strip()
        if clean_line and my_re.match(r'^[a-zA-Z0-9_:-]+$', clean_line):
            macros.add(clean_line)

    if not macros:
        system.exit("Error: 'show-macros-proper' returned no valid macros after sanitization.", status_code=1)

    debug.trace(TL.DETAILED, f"Sanitized macro list contains {len(macros)} items. Example: {list(macros)[:5]}")

    macro_stats = defaultdict(lambda: {'total': 0, 'bad': 0, 'bad_files': set()})

    output_files = _find_output_files(results_dir)
    if not output_files:
        print(f"No output files (*.outputpp.out) found in directory: {results_dir}")
        return []

    for output_file in output_files:
        # KEPT: .name is a convenient attribute of the Path object.
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
                "macro": macro,
                "bad": stats['bad'],
                "total": stats['total'],
                "pct_bad": pct_bad,
                "failing_in_files": sorted(list(stats['bad_files']))
            })

    return sorted(results, key=lambda x: (x['pct_bad'], x['bad']), reverse=True)


class Script(Main):
    """
    Input processing and failure analysis class.
    """
    # Class-level member variables for arguments
    results_dir = "."
    json_filename = None
    diagnostic_mode = False
    heuristic_mode = False

    def setup(self):
        """Check results of command line processing and initialize members."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        super().setup()
        self.results_dir = self._get_results_directory()
        self.diagnostic_mode = self.get_parsed_option(DIAGNOSTIC_MODE, self.diagnostic_mode)
        self.heuristic_mode = self.get_parsed_option(HEURISTIC_MODE, self.heuristic_mode)

        user_provided_filename = self.get_parsed_option(JSON_FILENAME, None)
        if user_provided_filename:
            self.json_filename = user_provided_filename
        elif self.heuristic_mode:
            self.json_filename = "failure_analyzer_heuristic.json"
        else:
            self.json_filename = "failure_analyzer_report.json"

        if self.results_dir is None:
            debug.trace(TL.ERROR, "Results directory is None after parsing, defaulting to '.'")
            system.print_error("Warning: Could not determine results directory from arguments, using current directory.")
            self.results_dir = "."

        self.results_dir, err_code = self._normalize_path(self.results_dir)
        if err_code != 0:
            # system.exit is called within _normalize_path on error
            return

        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def _get_results_directory(self):
        """Safely extract results directory from either positional or named arguments."""
        # The 'get_parsed_option' helper is not sufficient. We must inspect
        # the 'parsed_args' dictionary that the framework populates.
        if hasattr(self, 'parsed_args') and isinstance(self.parsed_args, dict):
            # Check for the named argument '--results-dir' first.
            if self.parsed_args.get('results-dir'):
                return self.parsed_args['results-dir']
        
        # If the named argument isn't found, fall back to the default.
        return "."

    def _normalize_path(self, path_str: str) -> tuple[str, int]:
        """Normalize path for cross-platform compatibility and validate existence."""
        # FIX: C0321 (multiple-statements)
        if not path_str:
            path_str = "."

        # MODIFIED: Using system.absolute_path instead of Path.resolve()
        abs_path = system.absolute_path(path_str)

        # MODIFIED: Using system.file_exists and system.is_directory
        if not system.file_exists(abs_path):
            system.exit(f"Error: Directory '{abs_path}' does not exist.", status_code=1)
            return abs_path, 1
        # FIX: R1705 (no-else-return)
        if not system.is_directory(abs_path):
            system.exit(f"Error: Path '{abs_path}' is not a directory.", status_code=1)
            return abs_path, 1

        return abs_path, 0

    # OLD: The methods _find_output_files, _find_failed_tests, and
    # _extract_from_generated_script were moved out of the class to become
    # standalone helper functions. This was done to allow the core logic
    # to be tested without instantiating the Script class. The old methods
    # are left here as wrappers for any internal class methods that might
    # still use them, ensuring backward compatibility within the class.
    def _find_output_files(self, root_dir: str) -> list[Path]:
        return _find_output_files(root_dir)

    def _find_failed_tests(self, output_file_path: Path) -> list[str]:
        return _find_failed_tests(output_file_path)

    def _extract_from_generated_script(self, script_path: Path, test_name: str) -> str | None:
        return _extract_from_generated_script(script_path, test_name)

    def _write_json_report(self, report_data: list, is_heuristic: bool):
        """Writes the analysis data to a JSON file."""
        print(f"\nWriting full report to {self.json_filename}...")

        if not is_heuristic:
            output_data = []
            for i, (command, data) in enumerate(report_data, 1):
                output_data.append({
                    "rank": i, "impact_score": data['impact'], "failure_count": data['count'],
                    "affected_files": len(data['sources']), "source_files": sorted(list(data['sources'])),
                    "suspect_command": command
                })
        else:
            output_data = report_data

        try:
            # MODIFIED: Using our own write_file wrapper could be an option,
            # but direct json.dump is standard and efficient. Sticking with this for now.
            with open(self.json_filename, 'w', encoding='utf-8') as f:
                json.dump(output_data, f, indent=2)
            print("JSON report generated successfully.")
        except IOError as e:
            system.exit(f"Error: Could not write JSON report to {self.json_filename}: {e}", status_code=1)

    def _analyze_test_run(self) -> list:
        """Orchestrates the original analysis, blaming test blocks."""
        # OLD: Logic moved to standalone analyze_test_run() for testability.
        # The class method now acts as a simple wrapper, passing its state
        # (self.results_dir) to the stateless helper function. This allows
        # the core logic to be unit-tested without creating a Script instance.
        #
        # aggregated_failures = defaultdict(lambda: {'sources': set(), 'count': 0})
        # print("--- Audit Trail: Processing Failure Logs (Original Mode) ---")
        # output_files = self._find_output_files(self.results_dir)
        # if not output_files:
        #     print(f"No output files (*.outputpp.out) found in directory: {self.results_dir}")
        #     return []
        # for output_file in output_files:
        #     failed_tests = self._find_failed_tests(output_file)
        #     if not failed_tests:
        #         continue
        #     base_name = output_file.name.replace('.outputpp.out', '')
        #     source_filename = f"{base_name}.batspp"
        #     generated_script_path = output_file.with_name(f"{base_name}.outputpp")
        #     print(f"  -> Analyzing {len(failed_tests)} failure(s) in: {source_filename}")
        #     for test_name in failed_tests:
        #         suspect = self._extract_from_generated_script(generated_script_path, test_name)
        #         if suspect:
        #             aggregated_failures[suspect]['sources'].add(source_filename)
        #             aggregated_failures[suspect]['count'] += 1
        # print("-" * 54)
        # if not aggregated_failures:
        #     return []
        # for data in aggregated_failures.values():
        #     data['impact'] = data['count'] * len(data['sources'])
        # return sorted(aggregated_failures.items(), key=lambda item: item[1]['impact'], reverse=True)

        # ADDED: Call the standalone helper function.
        return analyze_test_run(self.results_dir)

    def _analyze_macro_failures(self) -> list:
        """
        Estimates which macros/functions are failing the most and in which files.
        """
        # OLD: Logic moved to standalone analyze_macro_failures() for testability.
        # This follows the same pattern as _analyze_test_run, separating the
        # core analysis from the command-line application class.
        #
        # print("--- Running Macro Failure Heuristic Analysis ---")
        # try:
        #     raw_macros_output = gh.run("bash -c -i 'show-macros-proper'").splitlines()
        # except SystemError as e:
        #     system.exit(f"Error: Could not execute 'show-macros-proper'. Is it in your PATH? Details: {e}", status_code=1)
        # ... (rest of the original implementation) ...
        # return sorted(results, key=lambda x: (x['pct_bad'], x['bad']), reverse=True)

        # ADDED: Call the standalone helper function.
        return analyze_macro_failures(self.results_dir)

    def run_main_step(self):
        """
        Main processing step for the script.
        """
        # ADDED: Version bump to reflect refactoring.
        version = "v18-addon.8"
        print(f"Executing {version} analysis on target directory: {self.results_dir}\n")

        if self.heuristic_mode:
            sorted_macro_failures = self._analyze_macro_failures()
            if not sorted_macro_failures:
                print("\nAnalysis complete. No macro usage was found in test outputs.")
                return
            self._write_json_report(sorted_macro_failures, is_heuristic=True)

            print("\n--- Top 20 Suspect Macros/Functions (Sorted by Failure Rate) ---")
            headers = ['Rank', 'Macro/Function', 'Failure Rate', 'Bad Hits', 'Total Uses', 'Failing In']
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

                table_data.append([i, data['macro'], rate_str, data['bad'], data['total'], files_str])

            print(tabulate(table_data, headers=headers, tablefmt="fancy_grid", maxcolwidths=[None, None, None, None, None, 45]))
        else:
            sorted_failures = self._analyze_test_run()
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
