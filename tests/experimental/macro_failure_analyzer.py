#!/usr/bin/env python3
# -*- coding: utf-8 -*-

## TODO: Mezcla-fy the script with template.py

"""
Macro Failure Analyzer

Analyzes BATS test logs to identify macros most correlated with test failures.
The script examines test output files (*.out) to determine failure rates for each macro.

Features:
- Automatically detects macros using show-macros-proper
- Handles both direct file paths and directory scanning
- Calculates failure rates and presents ranked results
- Supports both interactive and non-interactive command execution
"""

import subprocess
import glob
from collections import defaultdict
import os
import argparse

def run_interactive_command(command_to_run):
    """Execute a command in an interactive bash shell with environment setup.
    
    Args:
        command_to_run (str): The command to execute
        
    Returns:
        str: The command output or empty string on failure
    """
    try:
        full_command_string = (
            'export PATH="$HOME/shell-scripts:$PATH"; '
            'source ~/.bashrc &>/dev/null; '
            f'{command_to_run}'
        )
        result = subprocess.run(
            ['bash', '-i', '-c', full_command_string],
            capture_output=True, text=True, check=True, timeout=20
        )
        return result.stdout.strip()
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError) as exc:
        print(f"Interactive command failed with stderr:\n{exc.stderr}")
        return ""

def run_command(command_to_run):
    """Execute a command directly with modified PATH environment.
    
    Args:
        command_to_run (str): The command to execute
        
    Returns:
        str: The command output or empty string on failure
    """
    try:
        env = os.environ.copy()
        env['PATH'] = f"{os.path.expanduser('~')}/shell-scripts:{env['PATH']}"
        result = subprocess.run(
            command_to_run,
            shell=True, capture_output=True, text=True, timeout=20, env=env,
            check=False  # Explicitly set check=False to handle errors manually
        )
        return result.stdout.strip()
    except subprocess.TimeoutExpired:
        return ""

def analyze_failures(log_pattern):
    """
    Analyze test logs to find macros with highest failure correlation.
    
    Args:
        log_pattern (str): Path pattern or directory for log files
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

    # Path handling logic
    expanded_path = os.path.expanduser(log_pattern)
    if os.path.isdir(expanded_path):
        print("INFO: Target path is a directory. Searching for '*.out' files within.")
        log_pattern = os.path.join(expanded_path, '*.out')

    log_files = glob.glob(os.path.expanduser(log_pattern))
    if not log_files:
        print(f"\nError: No log files found matching pattern '{log_pattern}'")
        print("Ensure tests have been run and the path is correct.")
        return
    print(f"Scanning {len(log_files)} log file(s)...")

    print("Analyzing log snippets for macro presence (non-interactive mode)...")
    for macro in macros:
        perlgrep_cmd = rf"perlgrep.perl -para '{macro}' {' '.join(log_files)}"
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
    parser = argparse.ArgumentParser(
        description="Analyzes BATS test logs to find macros most correlated with failures."
    )
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