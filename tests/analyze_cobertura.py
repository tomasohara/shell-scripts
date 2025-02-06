#! /usr/bin/env python

"""
Coverage analysis script for processing Cobertura XML reports and calculating test coverage metrics.

Sample usage:
   {script} --coverage-dir=tests/kcov-output
"""

# Standard modules
import xml.etree.ElementTree as ET
from collections import defaultdict
import os

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

# Constants
TL = debug.TL
COVERAGE_DIR = "coverage-dir"
COBERTURA_XML_REGEX = r".*/cobertura\.xml$"

class CoverageHelper:
    """Helper class for processing coverage data from Cobertura XML reports"""
    
    def __init__(self, coverage_dir):
        """Initializer: sets up coverage directory path"""
        debug.trace(TL.VERBOSE, f"CoverageHelper.__init__(): self={self}")
        self.coverage_dir = coverage_dir
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def find_cobertura_reports(self):
        """Find all Cobertura XML reports in the coverage directory."""
        reports = []
        pattern = my_re.compile(COBERTURA_XML_REGEX)
        
        ## TODO: Find mezcla alternative for os.walk
        for root, _, files in os.walk(self.coverage_dir):
            for file in files:
                filepath = gh.form_path(root, file)
                if pattern.match(filepath):
                    reports.append(filepath)
        return reports

    def parse_cobertura(self, cobertura_xml):
        """Parse Cobertura XML and extract coverage per script."""
        tree = ET.parse(cobertura_xml)
        root = tree.getroot()
        coverage_data = defaultdict(lambda: {'rates': [], 'total_lines': 0, 'covered_lines': 0})

        for class_elem in root.findall(".//class"):
            filename = class_elem.get("filename")
            script_name = filename.split("/")[-1]
            
            lines = class_elem.findall(".//line")
            total_lines = len(lines)
            covered_lines = sum(1 for line in lines if int(line.get("hits", "0")) > 0)
            coverage_rate = covered_lines / total_lines if total_lines > 0 else 0.0
            
            coverage_data[script_name]['rates'].append(coverage_rate)
            coverage_data[script_name]['total_lines'] += total_lines
            coverage_data[script_name]['covered_lines'] += covered_lines

        return coverage_data

    def aggregate_coverage(self):
        """Analyze all reports and compute aggregate coverage."""
        all_coverage = defaultdict(lambda: {'rates': [], 'total_lines': 0, 'covered_lines': 0})
        
        for report in self.find_cobertura_reports():
            report_data = self.parse_cobertura(report)
            for script, data in report_data.items():
                all_coverage[script]['rates'].extend(data['rates'])
                all_coverage[script]['total_lines'] += data['total_lines']
                all_coverage[script]['covered_lines'] += data['covered_lines']

        final_results = {}
        for script, data in all_coverage.items():
            avg_coverage = sum(data['rates']) / len(data['rates'])
            final_results[script] = {
                'coverage': avg_coverage,
                'total_lines': data['total_lines'],
                'covered_lines': data['covered_lines']
            }

        return final_results

class AnalyzeCobertura(Main):
    """Coverage analysis script class"""
    coverage_dir = gh.resolve_path("tests/kcov-output")

    def setup(self):
        """Check results of command line processing"""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        self.coverage_dir = self.get_parsed_option(COVERAGE_DIR, self.coverage_dir)
        self.helper = CoverageHelper(self.coverage_dir)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def run_main_step(self):
        """Main processing step"""
        debug.trace(5, f"Script.run_main_step(): self={self}")
        coverage_results = self.helper.aggregate_coverage()
        sorted_results = sorted(coverage_results.items(), 
                                key=lambda x: x[1]['coverage'], 
                                reverse=True)

        print("\nDetailed Coverage Summary (Aggregated):")
        print("-" * 120)
        print(f"{'#':<4} {'Script':<40} {'Extension':<10} {'Coverage':>10} {'Covered Lines':>15} {'Total Lines':>15}")
        print("-" * 120)

        macro_scores = []
        total_covered_lines = 0
        total_lines = 0

        for idx, (script, data) in enumerate(sorted_results, start=1):
            extension = script.split('.')[-1] if '.' in script else 'N/A'
            coverage_pct = data['coverage'] * 100
            covered = data['covered_lines']
            total = data['total_lines']

            macro_scores.append(coverage_pct)
            total_covered_lines += covered
            total_lines += total

            print(f"{idx:<4} {gh.elide(script, 35):<40} {extension:<10} {coverage_pct:>9.1f}% {covered:>15d} {total:>15d}")

        # Compute Macro and Micro Scores
        macro_score = sum(macro_scores) / len(macro_scores) if macro_scores else 0
        micro_score = (total_covered_lines / total_lines) * 100 if total_lines > 0 else 0

        print("-" * 120)
        print(f"{'Macro Score':<56} {macro_score:>9.1f}%")
        print(f"{'Micro Score':<56} {micro_score:>9.1f}% {total_covered_lines:>15d} {total_lines:>15d}")

def main():
    """Entry point"""
    app = AnalyzeCobertura(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        auto_help=True,
        text_options=[(COVERAGE_DIR, "Directory containing coverage reports")])
    app.run()

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()