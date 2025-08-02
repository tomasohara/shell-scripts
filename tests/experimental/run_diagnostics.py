#!/usr/bin/env python3

"""Automate the test execution and failure analysis pipeline (experimental)"""
## TODO: Mezcla-fy the script with template.py

# SCRIPT_NAME: run_diagnostics.py
# MISSION: Automate the test execution and failure analysis pipeline.
# VERSION: 1.2
# PATCH NOTES:
# - Added DIAG_VERBOSE flag to provide real-time test output to console.
# - Corrected data handoff to the analyzer script, which now receives
#   the output directory as a command-line argument.
# - Re-engineered pathing logic to be self-aware of script location.
# - Paths are now constructed relative to this file, not the current
#   working directory, ensuring robust execution from any location.
#
import sys

# Local Framework Modules
try:
    from mezcla import glue_helpers as gh
    from mezcla import system
    from mezcla.my_regex import my_re
except ImportError:
    # Cannot use system.exit if system module itself failed to import.
    print("CRITICAL: 'mezcla' framework not found. Ensure PYTHONPATH is correctly configured.")
    sys.exit(1)

# --- SELF-AWARENESS UPGRADE ---
# Determine the absolute directory where this script resides.
# All subsequent paths will be calculated from this fixed point.
SCRIPT_PATH = system.real_path(__file__)
SCRIPT_DIR, _ = system.split_path(SCRIPT_PATH)

# --- OPERATIONAL PARAMETERS ---
# Paths are now robustly constructed from the script's known location.
BATSPP_SOURCE_DIR = gh.form_path(SCRIPT_DIR, "batspp")
BATSPP_OUTPUT_DIR = gh.form_path(SCRIPT_DIR, "batspp-output")
ANALYZER_SCRIPT = gh.form_path(SCRIPT_DIR, "macro_failure_analyzer.py")
PROCESSOR_SCRIPT = gh.form_path(SCRIPT_DIR, "../../simple_batspp.py")

# PROTOCOL UPGRADE: VERBOSE MODE AWARENESS
IS_VERBOSE = system.getenv_value("DIAG_VERBOSE", "0") == "1"


def main():
    """
    Primary execution controller for the diagnostic mission.
    """
    print("="*60)
    print("INITIALIZING DIAGNOSTIC ORCHESTRATION PROTOCOL (v1.2)...")
    print("="*60)

    # --- PHASE 1: CONFIGURATION AND TARGET ACQUISITION ---

    gh.full_mkdir(BATSPP_OUTPUT_DIR)
    print(f"STATUS: Secure output channel established at '{BATSPP_OUTPUT_DIR}/'")

    # PROTOCOL UPGRADE: Announce verbose status
    if IS_VERBOSE:
        print("STATUS: Verbose mode is ACTIVE. Live tactical feed enabled.")
    else:
        print("STATUS: Verbose mode is INACTIVE. Output will be logged silently.")

    test_regex = system.getenv_value("TEST_REGEX", None, description="Regex for tests to include")
    if test_regex:
        print(f"INFO: Targeting filter active. TEST_REGEX = '{test_regex}'")
    else:
        print("INFO: No targeting filter. All operatives will be deployed.")

    # The operative now correctly reads from its own subdirectory.
    try:
        all_assets = system.read_directory(BATSPP_SOURCE_DIR)
    except FileNotFoundError:
        print(f"\nCRITICAL ERROR: Source directory not found at '{BATSPP_SOURCE_DIR}'.")
        print("Ensure the 'batspp' directory exists alongside the run_diagnostics.py script.")
        system.exit(1)

    target_files = []
    for asset in all_assets:
        if not asset.endswith(".batspp"):
            continue

        if test_regex and not my_re.search(fr"{test_regex}", asset):
            print(f"FILTER: Asset '{asset}' does not match target profile. Standing down.")
            continue
        
        target_files.append(asset)

    if not target_files:
        print(f"\nMISSION ABORTED: No valid targets acquired in '{BATSPP_SOURCE_DIR}'.")
        system.exit(1)

    print(f"\nTARGETS ACQUIRED: {len(target_files)} test asset(s) confirmed.")
    print("-" * 60)

    # --- PHASE 2: TEST EXECUTION ---

    print("BEGINNING TEST EXECUTION PHASE...")

    for batspp_file in target_files:
        input_path = gh.form_path(BATSPP_SOURCE_DIR, batspp_file)
        output_filename = batspp_file.replace('.batspp', '.bats.outputpp.out')
        output_path = gh.form_path(BATSPP_OUTPUT_DIR, output_filename)

        base_command = f"BASH_EVAL=1 GLOBAL_TEST_DIR=1 PARA_BLOCKS=1 python3 {PROCESSOR_SCRIPT} {input_path}"
        
        # PROTOCOL UPGRADE: DYNAMIC OUTPUT REDIRECTION
        if IS_VERBOSE:
            # Use `tee` to send output to both console and file
            command = f"{base_command} 2>&1 | tee {output_path}"
        else:
            # Original silent logging
            command = f"{base_command} > {output_path} 2>&1"

        print(f"  EXECUTING: {batspp_file}...")
        # For verbose mode, we want to see the output live, so we don't capture it here.
        gh.run(command, capture_output=False) 
        print(f"  LOGGED: Output secured at '{output_path}'")

    print("TEST EXECUTION PHASE COMPLETE.")
    print("-" * 60)

    # --- PHASE 3: FAILURE ANALYSIS ---

    print("BEGINNING AUTOMATED FAILURE ANALYSIS...")
    # PROTOCOL UPGRADE: DIRECTING THE ANALYZER
    # Pass the output directory as an argument so the analyzer knows where to find the logs.
    analysis_command = f"python3 {ANALYZER_SCRIPT} {BATSPP_OUTPUT_DIR}"
    print(f"  INVOKING: {analysis_command}")
    analysis_report = gh.run(analysis_command)

    print("ANALYSIS COMPLETE. FINAL REPORT FOLLOWS:")
    print("="*60)
    print(analysis_report)
    print("="*60)
    print("MISSION ACCOMPLISHED.")


if __name__ == '__main__':
    main()