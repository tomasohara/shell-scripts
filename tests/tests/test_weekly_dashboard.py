#!/usr/bin/env python3
#
"""Tests for weekly_dashboard.py."""

# Local modules
from pathlib import Path

from mezcla import debug
from mezcla.unittest_wrapper import TestWrapper, invoke_tests

import tests.weekly_dashboard as THE_MODULE


def write_file(path, text):
    """Write TEXT to PATH, creating its parent directory."""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


class TestIt(TestWrapper):
    """Test case definitions for weekly dashboard summaries."""

    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    def get_result_paths(self):
        """Return isolated paths for dashboard test results."""
        base_dir = Path(self.temp_file).parent / f"weekly-dashboard-{self.test_num}"
        return (
            base_dir / "test.log",
            base_dir / "aliases",
            base_dir / "kcov",
            base_dir / "environment.txt",
        )

    def test_01_reports_upticks_and_environment_changes(self):
        """Summaries identify tolerated failure upticks and version changes."""
        debug.trace(4, f"TestIt.test_01_reports_upticks_and_environment_changes(); self={self}")
        python_log, alias_reports, kcov_reports, environment = self.get_result_paths()
        write_file(
            python_log,
            "FYI: test_example.py 1 of 10 tests failed: 10.00%; success (90.00%); threshold=50%\n")
        write_file(alias_reports / "example.summary.txt",
                   "Success Score: 8 out of 10 (80.0%)\n"
                   "Success Status: True (Threshold: 50.0%)\n")
        write_file(kcov_reports / "example.js",
                   'var data = {"instrumented": 20, "covered": 15};\n')
        write_file(environment, "Python: 3.12.0\nBatsPP: 1.5.0\n")
        previous = {
            "environment": {"Python": "3.11.0", "BatsPP": "1.5.0"},
            "tests": {"python": {"failed": 0}, "aliases": {"failed": 1}},
            "coverage": {"percent": 80.0},
        }

        summary = THE_MODULE.make_summary(
            python_log, alias_reports, kcov_reports, environment, previous)

        self.do_assert(summary["tests"]["python"]["failed"] == 1)
        self.do_assert(summary["tests"]["aliases"]["failed"] == 2)
        self.do_assert(summary["coverage"]["percent"] == 75.0)
        self.do_assert(summary["changes"]["coverage_delta"] == -5.0)
        self.do_assert("Python failures increased by 1." in summary["changes"]["alerts"])
        self.do_assert(
            "Alias coverage dropped 5.00 percentage points." in summary["changes"]["alerts"])
        self.do_assert(summary["changes"]["environment"] == [
            {"name": "Python", "before": "3.11.0", "after": "3.12.0"}])

    def test_02_handles_the_first_dashboard_run(self):
        """The first run is explicitly marked as a baseline."""
        debug.trace(4, f"TestIt.test_02_handles_the_first_dashboard_run(); self={self}")
        python_log, alias_reports, kcov_reports, _environment = self.get_result_paths()
        write_file(
            python_log,
            "FYI: test_example.py 0 of 2 tests failed: 0.00%; success (100.00%); threshold=50%\n")
        write_file(alias_reports / "example.summary.txt",
                   "Success Score: 1 out of 1 (100.0%)\n")

        summary = THE_MODULE.make_summary(
            python_log, alias_reports, kcov_reports, None, None)
        self.do_assert(summary["changes"]["baseline"])
        self.do_assert("baseline report" in THE_MODULE.format_markdown(summary))
        self.do_assert("baseline report" in THE_MODULE.format_markdown(summary))


if __name__ == "__main__":
    invoke_tests(__file__)
