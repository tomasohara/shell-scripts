"""Master test script for shell-scripts repo"""
import sys
import re
import subprocess
import yaml


def load_thresholds(filename):
    """Load test failure thresholds from a YAML file."""
    with open(filename, "r", encoding="utf-8") as yamlfile:
        return yaml.safe_load(yamlfile)


def run_tests(thresholds):
    """Run tests and compare the results with the allowed thresholds"""
    failed = 0
    for test, threshold in thresholds.items():
        # Collect test cases for the test
        cmd = f"pytest -k tests/{test} --collect-only"
        result = subprocess.run(
            cmd, shell=True, text=True, capture_output=True
        )
        total_tests = len(
            re.findall(
                r"<TestCaseFunction|<TestCaseClass|<Function|<Class", result.stdout
            )
        )

        # Run tests for the test
        cmd = f"pytest {test}"
        result = subprocess.run(
            cmd, shell=True, text=True, capture_output=True
        )
        failed_tests = len(re.findall(r"FAILED", result.stdout))
        print(result)
        # Calculate the number of allowed failures
        allowed_failures = total_tests * (threshold / 100)

        # Check if the number of failed tests exceeds the allowed threshold
        if total_tests == 0:
            print(f"WARNING: No tests were found for test {test}.")
        elif failed_tests > allowed_failures:
            print(
                f"ERROR: {test} failed {failed_tests} tests ({failed_tests/total_tests*100:.2f}%), exceeding the allowed threshold of {threshold}%"
            )
            failed += 1
            continue
    if failed > 0:
        sys.exit(1)



def main():
    """Main function"""
    # Load the thresholds from the YAML file
    thresholds = load_thresholds("tests/thresholds.yaml")
    # Run tests and compare the results with the allowed thresholds
    run_tests(thresholds)


if __name__ == "__main__":
    main()
