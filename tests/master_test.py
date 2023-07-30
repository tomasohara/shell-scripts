#!/usr/bin/env python3
#
# note: Tana's script for running Python tests as part of workflow
#


"""Master test script for shell-scripts repo"""

# Standard modules
import math
import subprocess

# Installed modules
import yaml

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system

# Environment options
# Note: These are just intended for internal options, not for end users.
#
TEST_REGEX = system.getenv_value("TEST_REGEX", None,
                                 "Regex for tests to include; ex: 'c.*' for debugging")

#-------------------------------------------------------------------------------
# Utility functions

def load_thresholds(filename):
    """Load test failure thresholds from a YAML file."""
    result = None
    with system.open_file(gh.resolve_path(filename)) as f:
        try:
            result = yaml.safe_load(f)
        except:
            system.print_exception_info("load_thresholds")
    debug.trace(6, "load_thresholds({filename}) => {result!r}")
    return result


def round_p2str(num):
    """Round NUM using precision of 3"""
    # EX: round_p2str(1.678) => "1.68"
    # EX: round_p2str(1.6) => "1.60"
    return system.round_as_str(num, 2)

#-------------------------------------------------------------------------------
# Main code

def run_tests(thresholds):
    """Run tests and compare the results with the allowed thresholds"""
    failed = 0
    for test_filename, threshold in thresholds.items():
        debug.trace_expr(4, test_filename, threshold)
        test_path = gh.resolve_path(test_filename)

        # Exclude certain test files (e.g., non-python test files listed in thresholds.yml)
        include = True
        if not my_re.search(r"^test_.*\.py$", gh.basename(test_filename)):
            debug.trace(5, f"Ignoring non-python test: {test_filename}")
            include = False
        elif TEST_REGEX and not my_re.search(rf"{TEST_REGEX}", test_filename):
            debug.trace(5, f"Filtering test {test_filename} not matching TEST_REGEX ({TEST_REGEX})")
            include = False
        if not include:
            continue

        # Collect test cases for the test
        ## BAD: cmd = f"pytest -k {test} --collect-only"
        cmd = f"pytest --collect-only {test_path}"
        collect_result = subprocess.run(cmd, shell=True, text=True, capture_output=True, check=False)
        debug.trace_object(6, collect_result)
        total_tests = len(my_re.findall(r"<TestCaseFunction|<TestCaseClass|<Function|<Class",
                                        collect_result.stdout))

        # Run tests for the test
        cmd = f"pytest {test_path}"
        run_result = subprocess.run(cmd, shell=True, text=True, capture_output=True, check=False)
        debug.trace_object(6, run_result)
        failed_tests = len(my_re.findall(r"FAILED", run_result.stdout))
        debug.assertion(failed_tests <= total_tests)

        # Calculate the number of allowed failures
        # note: threshold is for success (e.g., 51 means 51% of tests passed)
        # TODO3: have sanity checks account for minor floatiing point differences
        required_successes = (math.ceil(total_tests * threshold / 100) if threshold else 0)
        debug.assertion(0 <= required_successes <= total_tests)
        allowed_failures = max(1 - required_successes, 0)

        # Check if the number of failed tests exceeds the allowed threshold
        if total_tests == 0:
            print(f"Warning: No tests were found for test {test_path}.")
            debug.trace_expr(5, collect_result.stdout, collect_result.stderr)
            continue
        module_failure = (failed_tests and (failed_tests <= allowed_failures))
        failed_percent = round_p2str(failed_tests / total_tests * 100)
        debug.trace_expr(6, failed_tests, allowed_failures, total_tests, module_failure, required_successes)

        # Format message to stdout: either error, warning or FYI on test summary.
        label = ("Error" if module_failure else "Warning" if failed_tests else "FYI")
        print(f"{label}: {test_filename} {failed_tests} of {total_tests} tests failed ({failed_percent}%)",
              end="")
        if module_failure:
            num_good = (total_tests - failed_tests)
            short = (required_successes - num_good)
            debug.assertion(0 <= required_successes <= total_tests)
            debug.assertion(0 <= short <= (total_tests - failed_tests) <= total_tests)
            print((f": {short} short of the {required_successes} required successes" +
                   f" (i.e., {round_p2str(threshold)}+%)"), end="")
            failed += 1
        print(".")

    # Return status code (e.g., for use in workflow): 0 if OK otherwise # failed.
    message = "All OK"
    code = 0
    if failed > 0:
        code = failed
        message = "Error: {failed} modules failed"
    system.exit(message, status_code=code)

#-------------------------------------------------------------------------------

def main():
    """Main function"""

    # Load the thresholds from the YAML file, falling back to defaults for all test files
    # in the tests directory (TODO: merge the two sources with file trumping default).
    # note: uses default of 25% succeses allowed just for sake of getting tests operational
    # under Github actions (TODO: lower to 50%).
    THRESHOLDS_FILE = "thresholds.yaml"
    thresholds = {test_file: 25.0 for test_file in gh.get_matching_files("tests/test_*.py")}
    debug.trace_expr(5, thresholds, "default thresholds")
    if system.file_exists(THRESHOLDS_FILE):
        thresholds.update(load_thresholds(THRESHOLDS_FILE))
        debug.trace_expr(5, thresholds, "final thresholds")
    
    # Run tests and compare the results with the allowed thresholds
    run_tests(thresholds)


if __name__ == "__main__":
    main()
