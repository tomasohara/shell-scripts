#!/usr/bin/env python3
#
# Generate a compact weekly test-dashboard record from the existing test output.
# The record is designed for GitHub Actions artifacts, so a later dashboard can
# consume a stable JSON schema without re-running the tests.
#
## NOTE: Initial dashboard reporting facilitated by GitHub Copilot (GPT-5.6 Terra).

"""
Create a weekly summary of Python, alias, and Kcov test results.

The GitHub Actions workflow retains the JSON result as an artifact and uses the
Markdown result for the Actions summary and optional SMTP email.

Sample usage:
   {script} --python-log=test-results/test-run.log \
       --alias-reports=test-results/batspp/txt-reports \
       --kcov-reports=test-results/batspp/kcov-output \
       --output=test-results/weekly-summary.json \
       --markdown=test-results/weekly-summary.md
"""

import json
import re
from datetime import datetime, timezone
from pathlib import Path

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main


TL = debug.TL
PYTHON_RESULT = re.compile(
    r"^(?:FYI|Warning|Error): (?P<name>test_[^ ]+\.py) "
    r"(?P<failed>\d+) of (?P<total>\d+) tests failed:")
ALIAS_RESULT = re.compile(
    r"^Success Score: (?P<passed>\d+) out of (?P<total>\d+) \((?P<rate>[\d.]+)%\)$")
KCOV_RESULT = re.compile(
    r'"instrumented"\s*:\s*(?P<instrumented>\d+).*?"covered"\s*:\s*(?P<covered>\d+)')
VERSION_RESULT = re.compile(r"^(?P<name>[^:]+):\s*(?P<value>.+)$")
ALERT_COVERAGE_DROP = 2.0
MAX_CHANGED_TESTS = 8

PYTHON_LOG_ARG = "python-log"
ALIAS_REPORTS_ARG = "alias-reports"
KCOV_REPORTS_ARG = "kcov-reports"
ENVIRONMENT_ARG = "environment"
PREVIOUS_ARG = "previous"
OUTPUT_ARG = "output"
MARKDOWN_ARG = "markdown"


def load_json(path):
    """Return JSON from PATH, or None when PATH does not exist."""
    return json.loads(path.read_text(encoding="utf-8")) if path and path.exists() else None


def parse_python_log(path):
    """Return Python test counts indexed by module name from PATH."""
    results = {}
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = PYTHON_RESULT.match(line)
        if match:
            results[match["name"]] = {
                "failed": int(match["failed"]),
                "total": int(match["total"]),
            }
    return results


def parse_alias_reports(directory):
    """Return BatsPP success counts indexed by notebook-derived report name."""
    results = {}
    for path in sorted(directory.glob("*.summary.txt")):
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            match = ALIAS_RESULT.match(line)
            if match:
                results[path.name.removesuffix(".summary.txt")] = {
                    "passed": int(match["passed"]),
                    "total": int(match["total"]),
                }
                break
    return results


def parse_kcov_reports(directory):
    """Return the aggregate Kcov covered and instrumented line counts."""
    covered = instrumented = 0
    for path in directory.rglob("*.js"):
        match = KCOV_RESULT.search(path.read_text(encoding="utf-8", errors="replace"))
        if match:
            instrumented += int(match["instrumented"])
            covered += int(match["covered"])
    return {"covered": covered, "instrumented": instrumented}


def parse_environment(path):
    """Return the recorded test environment versions from PATH."""
    results = {}
    if not path or not path.exists():
        return results
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = VERSION_RESULT.match(line)
        if match:
            results[match["name"]] = match["value"]
    return results


def summarize_results(results, success_key):
    """Return aggregate passed, failed, and total counts for RESULTS."""
    total = sum(result["total"] for result in results.values())
    passed = sum(result.get(success_key, result["total"] - result.get("failed", 0))
                 for result in results.values())
    return {"passed": passed, "failed": total - passed, "total": total, "by_test": results}


def coverage_percent(coverage):
    """Return coverage percentage, or None when no lines were instrumented."""
    return (round(coverage["covered"] / coverage["instrumented"] * 100, 2)
            if coverage["instrumented"] else None)


def find_changes(current, previous):
    """Return actionable aggregate, environment, and test-level changes."""
    if not previous:
        return {"baseline": True, "alerts": [], "tests": [], "environment": []}

    changes = {"baseline": False, "alerts": [], "tests": [], "environment": []}
    for suite in ("python", "aliases"):
        failed_delta = current["tests"][suite]["failed"] - previous["tests"][suite]["failed"]
        if failed_delta:
            changes["tests"].append({"suite": suite, "failed_delta": failed_delta})
            if failed_delta > 0:
                changes["alerts"].append(
                    f"{suite.title()} failures increased by {failed_delta}.")

    current_coverage = current["coverage"]["percent"]
    previous_coverage = previous.get("coverage", {}).get("percent")
    if current_coverage is not None and previous_coverage is not None:
        coverage_delta = round(current_coverage - previous_coverage, 2)
        if coverage_delta:
            changes["coverage_delta"] = coverage_delta
        if coverage_delta <= -ALERT_COVERAGE_DROP:
            changes["alerts"].append(
                f"Alias coverage dropped {abs(coverage_delta):.2f} percentage points.")

    previous_environment = previous.get("environment", {})
    for name, value in current["environment"].items():
        if name in previous_environment and value != previous_environment[name]:
            changes["environment"].append(
                {"name": name, "before": previous_environment[name], "after": value})
    if changes["environment"]:
        changes["alerts"].append("Supporting software versions changed.")
    return changes


def make_summary(python_log, alias_reports, kcov_reports, environment, previous):
    """Build a versioned dashboard record from the collected result files."""
    python_results = parse_python_log(python_log)
    alias_results = parse_alias_reports(alias_reports)
    coverage = parse_kcov_reports(kcov_reports)
    coverage["percent"] = coverage_percent(coverage)
    summary = {
        "schema_version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "environment": parse_environment(environment),
        "tests": {
            "python": summarize_results(python_results, "passed"),
            "aliases": summarize_results(alias_results, "passed"),
        },
        "coverage": coverage,
    }
    summary["changes"] = find_changes(summary, previous)
    return summary


def format_markdown(summary):
    """Format SUMMARY for the Actions step summary and optional email body."""
    lines = ["# Weekly test dashboard", ""]
    for suite in ("python", "aliases"):
        result = summary["tests"][suite]
        lines.append(
            f"- **{suite.title()} tests:** {result['passed']}/{result['total']} passed "
            f"({result['failed']} failed)")
    coverage = summary["coverage"]
    coverage_display = (f"{coverage['percent']:.2f}%" if coverage["percent"] is not None
                        else "not available")
    lines.append(
        f"- **Alias coverage:** {coverage_display} "
        f"({coverage['covered']}/{coverage['instrumented']} lines)")

    changes = summary["changes"]
    if changes["baseline"]:
        lines.extend(["", "> This is the baseline report; no prior weekly artifact was available."])
    elif changes["alerts"]:
        lines.extend(["", "## Changes requiring attention"])
        lines.extend(f"- {alert}" for alert in changes["alerts"])
    else:
        lines.extend(["", "## Changes", "- No aggregate regressions from the prior weekly run."])

    if changes["environment"]:
        lines.extend(["", "## Environment changes"])
        lines.extend(
            f"- **{change['name']}:** `{change['before']}` -> `{change['after']}`"
            for change in changes["environment"])
    lines.extend([
        "",
        "Detailed per-test results and Kcov HTML are attached to this workflow run.",
    ])
    return "\n".join(lines) + "\n"


class WeeklyDashboard(Main):
    """Process dashboard input files into JSON and Markdown summaries."""

    python_log = None
    alias_reports = None
    kcov_reports = None
    environment = None
    previous = None
    output = None
    markdown = None

    def setup(self):
        """Read paths supplied through dashboard command-line options."""
        self.python_log = self.get_parsed_option(PYTHON_LOG_ARG)
        self.alias_reports = self.get_parsed_option(ALIAS_REPORTS_ARG)
        self.kcov_reports = self.get_parsed_option(KCOV_REPORTS_ARG)
        self.environment = self.get_parsed_option(ENVIRONMENT_ARG)
        self.previous = self.get_parsed_option(PREVIOUS_ARG)
        self.output = self.get_parsed_option(OUTPUT_ARG)
        self.markdown = self.get_parsed_option(MARKDOWN_ARG)
        required_options = (self.python_log, self.alias_reports, self.kcov_reports,
                            self.output, self.markdown)
        debug.assertion(all(required_options), "Required dashboard option missing")
        debug.trace_object(TL.VERBOSE, self,
                           label=f"{self.__class__.__name__} instance")

    def run_main_step(self):
        """Write the dashboard summary using the supplied result directories."""
        summary = make_summary(
            Path(self.python_log), Path(self.alias_reports), Path(self.kcov_reports),
            Path(self.environment) if self.environment else None,
            load_json(Path(self.previous)) if self.previous else None)
        Path(self.output).write_text(
            json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        Path(self.markdown).write_text(format_markdown(summary), encoding="utf-8")


def main():
    """Run the weekly dashboard command-line application."""
    app = WeeklyDashboard(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        auto_help=True,
        text_options=[
            (PYTHON_LOG_ARG, "Path to the Python and BatsPP test output log"),
            (ALIAS_REPORTS_ARG, "Directory with BatsPP text summary files"),
            (KCOV_REPORTS_ARG, "Directory with Kcov report data"),
            (ENVIRONMENT_ARG, "Path to the tested software version record"),
            (PREVIOUS_ARG, "Path to the previous weekly dashboard JSON"),
            (OUTPUT_ARG, "Output path for the dashboard JSON"),
            (MARKDOWN_ARG, "Output path for the dashboard Markdown"),
        ])
    app.run()


if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()
