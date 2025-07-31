#!/usr/bin/env python3
#
# SCRIPT_NAME: macro_failure_analyzer.py
# MISSION: Analyze BATS test logs to find macros most correlated with failures.
# VERSION: 1.3
# PATCH NOTES:
# - Made log path handling robust. Script now correctly searches for '*.out'
#   files when given a directory path, preventing command protocol errors.
# - CORRECTED SENSORY FLAW: Removed 'check=True' from run_command.
#

import subprocess
import glob
from collections import defaultdict
import os
import argparse

def run_interactive_command(command_to_run):
    # ... (no changes to this function)
    try:
        full_command_string = (
            f'export PATH="$HOME/shell-scripts:$PATH"; '
            f'source ~/.bashrc &>/dev/null; '
            f'{command_to_run}'
        )
        result = subprocess.run(
            ['bash', '-i', '-c', full_command_string],
            capture_output=True, text=True, check=True, timeout=20
        )
        return result.stdout.strip()
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError) as e:
        print(f"Interactive command failed with stderr:\n{e.stderr}")
        return ""

def run_command(command_to_run):
    # ... (no changes to this function)
    try:
        env = os.environ.copy()
        env['PATH'] = f"{os.path.expanduser('~')}/shell-scripts:{env['PATH']}"
        result = subprocess.run(
            command_to_run,
            shell=True, capture_output=True, text=True, timeout=20, env=env
        )
        return result.stdout.strip()
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError) as e:
        return ""

def analyze_failures(log_pattern):
    """
    Implements the failure analysis heuristic with robust path handling.
    """
    print("--- Running Failure Analysis Heuristic (v1.3) ---")
    
    num_total = defaultdict(int)
    num_bad = defaultdict(int)

    print("Fetching macros using 'show-macros-proper' (interactive mode)...")
    macros = run_interactive_command("show-macros-proper").split()
    if not macros:
        print("\nFatal Error: Could not fetch macros. Analysis cannot continue.")
        return
    print(f"Found {len(macros)} macros/functions to analyze.")

    # --- PATHING LOGIC UPGRADE ---
    # The operative now checks if the provided path is a directory.
    # If so, it intelligently appends the standard log file pattern.
    expanded_path = os.path.expanduser(log_pattern)
    if os.path.isdir(expanded_path):
        print(f"INFO: Target path is a directory. Searching for '*.out' files within.")
        log_pattern = os.path.join(expanded_path, '*.out')

    log_files = glob.glob(os.path.expanduser(log_pattern))
    if not log_files:
        print(f"\nError: No log files found matching pattern '{log_pattern}'")
        print("Ensure tests have been run and the path is correct.")
        return
    print(f"Scanning {len(log_files)} log file(s)...")

    print("Analyzing log snippets for macro presence (non-interactive mode)...")
    for macro in macros:
        perlgrep_cmd = fr"perlgrep.perl -para '{macro}' {' '.join(log_files)}"
        snippets_output = run_command(perlgrep_cmd)

        if not snippets_output:
            continue

        for snippet in snippets_output.split('\n\n'):
            if not snippet:
                continue
            
            num_total[macro] += 1
            if "not ok" in snippet:
                num_bad[macro] += 1

    if not num_total:
        print("\nAnalysis complete. No usage of the found macros was detected in the logs.")
        return
        
    results = []
    for macro in num_total:
        if num_total[macro] > 0:
            pct = (num_bad[macro] / num_total[macro]) * 100
            results.append((macro, num_bad[macro], num_total[macro], pct))

    results.sort(key=lambda item: (item[3], item[2]), reverse=True)

    print("\n--- Failure Analysis Report ---")
    print(f"{'Suspect Macro/Function':<30} {'Failures':<10} {'Total Uses':<12} {'Failure Rate':<15}")
    print("-" * 70)
    for macro, bad, total, pct in results:
        print(f"{macro:<30} {bad:<10} {total:<12} {pct:.2f}%")


if __name__ == "__main__":
    # ... (no changes to the parser itself)
    parser = argparse.ArgumentParser(description="Analyzes BATS test logs to find macros most correlated with failures.")
    parser.add_argument(
        'log_files',
        nargs='?',
        default=None,
        help="Path pattern or directory for log files. If not provided, the script expects the path from an orchestrator."
    )
    args = parser.parse_args()

    log_path_pattern = args.log_files
    if log_path_pattern is None:
        default_dir = os.path.expanduser('~/shell-scripts/tests/batspp-output')
        print(f"INFO: No log path provided. Using default fallback: {default_dir}")
        log_path_pattern = default_dir

    analyze_failures(log_path_pattern)