#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# test_aliases.py: Discovers and tests shell aliases from a source file.
#
# This script uses a direct-execution model, sourcing an alias file into a
# non-interactive bash shell to discover and test aliases without external
# test runners like bats-core. It prioritizes portability and robustness.
#

"""
A framework to automatically discover and test shell aliases directly.

This script is designed to improve the testing workflow for shell scripts
by automating the validation of aliases in a dependency-free manner.

Sample usage:
   {script} --alias-file ~/shell-scripts/tomohara-aliases.bash --verbose
"""

# Standard modules
import os
import re
import shutil
import subprocess
import tempfile

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main

# Constants for command-line switches
ALIAS_FILE = "alias-file"
VERBOSE = "verbose"
IGNORE_ALIASES = "ignore-aliases"
XFAIL_ALIASES = "xfail-aliases"
SELECT_ALIASES = "select-aliases"

# Constants
TL = debug.TL

class Script(Main):
    """
    Main class for discovering and directly testing aliases by replicating
    the user's configured shell environment.
    """
    alias_file = ""
    verbose = False
    bash_executable = None
    bashrc_path = ""
    ignore_list = set()
    xfail_list = set()
    select_list = set()
    
    def setup(self):
        """Check and store results of command line processing."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        
        default_alias_file = os.path.expanduser("~/shell-scripts/tomohara-aliases.bash")
        self.alias_file = self.get_parsed_option(ALIAS_FILE, default_alias_file)
        self.verbose = self.get_parsed_option(VERBOSE, self.verbose)

        self.bash_executable = shutil.which("bash")
        if not self.bash_executable:
            raise FileNotFoundError("Critical Error: 'bash' not found in PATH.")
        debug.trace(6, f"Using bash executable: {self.bash_executable}")

        self.bashrc_path = os.path.expanduser("~/.bashrc")
        if not os.path.exists(self.bashrc_path):
            debug.trace(TL.WARNING, "User ~/.bashrc file not found. Tests may be inaccurate.")
            self.bashrc_path = ""
        else:
            debug.trace(6, f"Located environment setup file: {self.bashrc_path}")

        ignored_str = self.get_parsed_option(IGNORE_ALIASES, "")
        if ignored_str:
            self.ignore_list = set(name.strip() for name in ignored_str.split(','))
            debug.trace(6, f"Will ignore {len(self.ignore_list)} aliases.")

        xfail_str = self.get_parsed_option(XFAIL_ALIASES, "")
        if xfail_str:
            self.xfail_list = set(name.strip() for name in xfail_str.split(','))
            debug.trace(6, f"Will expect {len(self.xfail_list)} aliases to fail.")

        select_str = self.get_parsed_option(SELECT_ALIASES, "")
        if select_str:
            self.select_list = set(name.strip() for name in select_str.split(','))
            debug.trace(6, f"Will select {len(self.select_list)} specific aliases for testing.")

        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def _get_base_setup_command(self):
        """Constructs the setup command string to replicate the shell environment."""
        setup_environment = f"PS1='dummy' && source '{self.bashrc_path}'" if self.bashrc_path else ""
        absolute_alias_path = os.path.abspath(self.alias_file)
        return f"{setup_environment} && shopt -s expand_aliases && source '{absolute_alias_path}'"

    def run_main_step(self):
        """Main processing step: discover, select, filter, and run tests."""
        if not os.path.exists(self.alias_file):
            print(f"Error: Alias file not found at '{self.alias_file}'")
            return

        all_aliases = self._discover_aliases_directly()
        if not all_aliases:
            print("No aliases were discovered. Check for errors above.")
            return
        
        candidate_aliases = all_aliases

        if self.select_list:
            print(f"--- Selecting {len(self.select_list)} specified aliases for testing ---")
            all_discovered_set = set(all_aliases)
            selected_and_found = self.select_list.intersection(all_discovered_set)
            
            not_found = self.select_list - all_discovered_set
            if not_found:
                print(f"Warning: The following selected aliases were not found and will be skipped: {', '.join(not_found)}")
            
            candidate_aliases = [alias for alias in all_aliases if alias in selected_and_found]

        aliases_to_test = [alias for alias in candidate_aliases if alias not in self.ignore_list]
        
        ignored_count = len(candidate_aliases) - len(aliases_to_test)
        if ignored_count > 0:
            print(f"--- Ignoring {ignored_count} specified aliases from the test run ---")

        self._run_direct_tests_and_report(aliases_to_test)

    def _discover_aliases_directly(self):
        """Uses a non-interactive shell to list aliases after building the environment."""
        debug.trace(6, "Discovering aliases within a controlled, non-interactive environment.")
        setup_command = self._get_base_setup_command()
        command = f"{setup_command} && eval alias"
        
        ## FIX: Explicitly set check=False to satisfy the W1510 linter warning.
        ## Our code handles the return code manually, so this makes our intent clear.
        result = subprocess.run(
            [self.bash_executable, "-c", command],
            capture_output=True, text=True, encoding='utf-8',
            stdin=subprocess.DEVNULL, check=False
        )

        if result.returncode != 0:
            ## FIX: Removed unnecessary f-string for W1309.
            print("Error: Failed during alias discovery. Bash returned an error.")
            if result.stderr:
                print(f"--- BASH STDERR ---\n{result.stderr.strip()}\n-------------------")
            return []

        discovered_aliases = []
        alias_pattern = re.compile(r"alias\s+([^=]+)='(.*)'")
        for line in result.stdout.strip().split('\n'):
            match = alias_pattern.match(line)
            if match:
                discovered_aliases.append(match.group(1))

        debug.trace(6, f"Discovered {len(discovered_aliases)} aliases.")
        return discovered_aliases

    def _run_direct_tests_and_report(self, aliases):
        """Tests each alias, categorizing results and showing output intelligently."""
        debug.trace(6, f"Executing direct tests for {len(aliases)} aliases.")
        results = {"passed": [], "failed": [], "xfailed": [], "xpassed": []}
        setup_command = self._get_base_setup_command()

        show_output = self.verbose or bool(self.select_list)

        print(f"\n--- Running {len(aliases)} Alias Tests ---")
        
        for i, alias_name in enumerate(aliases):
            command_to_test = f"{setup_command} && eval {alias_name}"
            print(f"\n({i+1}/{len(aliases)}) Testing alias: '{alias_name}'")
            is_xfail = alias_name in self.xfail_list

            try:
                with tempfile.TemporaryDirectory() as temp_dir:
                    process = subprocess.Popen(
                        [self.bash_executable, "-c", command_to_test],
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                        text=True, encoding='utf-8', errors='replace',
                        cwd=temp_dir, stdin=subprocess.DEVNULL
                    )
                    stdout, stderr = process.communicate(timeout=15)
                    return_code = process.returncode

                def print_output_block(out, err):
                    if show_output and out:
                        ## FIX: Removed unnecessary f-string for W1309.
                        print("    [STDOUT]:")
                        print("\n".join([f"      {line}" for line in out.strip().split('\n')]))
                    if show_output and err:
                        ## FIX: Removed unnecessary f-string for W1309.
                        print("    [STDERR]:")
                        print("\n".join([f"      {line}" for line in err.strip().split('\n')]))

                if return_code == 0:
                    if is_xfail:
                        results["xpassed"].append(alias_name)
                        print("  - [XPASS] Result: 0 (This was expected to fail but passed)")
                    else:
                        results["passed"].append(alias_name)
                        print("  - [PASS] Result: 0")
                    print_output_block(stdout, stderr)
                else:
                    failure_info = {"name": alias_name, "code": return_code, "stdout": stdout.strip(), "stderr": stderr.strip()}
                    if is_xfail:
                        results["xfailed"].append(failure_info)
                        print("  - [XFAIL] Result: {return_code} (Failure was expected)")
                    else:
                        results["failed"].append(failure_info)
                        print("  - [FAIL] Result: {return_code}")
                    print_output_block(stdout, stderr)

            except subprocess.TimeoutExpired:
                process.kill()
                stdout, stderr = process.communicate()
                failure_info = {"name": alias_name, "code": "TIMEOUT", "stdout": stdout.strip(), "stderr": "Process timed out after 15 seconds."}
                if is_xfail:
                    results["xfailed"].append(failure_info)
                    print("  - [XFAIL] Result: TIMEOUT (Failure was expected)")
                else:
                    results["failed"].append(failure_info)
                    print("  - [FAIL] Result: TIMEOUT")
                if show_output and stderr:
                     print(f"    [STDERR]: {failure_info['stderr']}")

            ## FIX: Silenced the W0718 warning. Catching a broad exception is intentional here
            ## to ensure any unexpected error in one test doesn't crash the entire suite.
            except Exception as e:  # pylint: disable=broad-exception-caught
                failure_info = {"name": alias_name, "code": "EXCEPTION", "stderr": str(e)}
                results["failed"].append(failure_info)
                ## FIX: Removed unnecessary f-string for W1309.
                print("  - [FAIL] Result: EXCEPTION")
                print(f"    [ERROR]: {str(e)}")

        passed_count = len(results["passed"])
        failed_count = len(results["failed"])
        xfailed_count = len(results["xfailed"])
        xpassed_count = len(results["xpassed"])
        
        print("\n\n--- Alias Test Report ---")
        print(f"Alias File: {self.alias_file}")
        print(f"Summary: {len(aliases)} tests run -> "
              f"{passed_count} passed, {failed_count} failed, "
              f"{xfailed_count} expected failures (xfail), {xpassed_count} unexpected passes (xpass)")
        ## FIX: Removed unnecessary f-string for W1309.
        print("-------------------------\n")

        if results["failed"]:
            ## FIX: Removed unnecessary f-string for W1309.
            print("Unexpected Failures (Require Investigation):")
            for failure in results["failed"]:
                print(f"  - [FAIL] {failure['name']} (Result: {failure['code']})")
                if failure.get('stderr') and self.verbose:
                    stderr_summary = (failure['stderr'].split('\n')[0])
                    print(f"      [Info]: {stderr_summary}")
            print("")
        
        if results["xpassed"]:
            ## FIX: Removed unnecessary f-string for W1309.
            print("Unexpected Passes (Review `xfail` List):")
            for alias_name in results["xpassed"]:
                print(f"  - [XPASS] {alias_name}")
            print("")
                 
def main():
    """Entry point"""
    app = Script(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        text_options=[
            (ALIAS_FILE, "Path to the alias file to test (e.g., tomohara-aliases.bash)"),
            (IGNORE_ALIASES, "A comma-separated list of aliases to ignore during testing."),
            (XFAIL_ALIASES, "A comma-separated list of aliases that are expected to fail."),
            (SELECT_ALIASES, "A comma-separated list of specific aliases to test, ignoring all others.")
        ],
        boolean_options=[
            (VERBOSE, "Enable verbose output to show pass/fail status for each alias.")
        ])
    app.run()
    debug.assertion(not any(re.search(r"^TODO_", m, re.IGNORECASE)
                            for m in dir(app)))

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__, "Please fill out the main docstring.")
    main()