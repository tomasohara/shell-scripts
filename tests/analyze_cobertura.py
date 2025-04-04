#! /usr/bin/env python

"""
Coverage analysis script for processing Cobertura XML reports and calculating test coverage metrics.

Sample usage:
   {script} --coverage-dir=tests/kcov-output
   {script} --coverage-dir=tests/kcov-output --json
"""

# Standard modules
import re
import json
import xml.etree.ElementTree as ET
from collections import defaultdict

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

# Constants
TL = debug.TL
COVERAGE_DIR = "coverage-dir"
JSON_OUTPUT = "json"
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
        pattern = re.compile(COBERTURA_XML_REGEX)

        def scan_directory(directory):
            for entry in gh.get_directory_listing(directory):
                filepath = gh.form_path(directory, entry)
                if gh.is_directory(filepath):
                    scan_directory(filepath)
                elif filepath.endswith(".xml") and pattern.match(filepath):  # If XML file matches regex
                    reports.append(filepath)

        scan_directory(self.coverage_dir)
        return sorted(reports)

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
            avg_coverage = sum(data['rates']) / len(data['rates']) if data['rates'] else 0
            final_results[script] = {
                'coverage': avg_coverage,
                'total_lines': data['total_lines'],
                'covered_lines': data['covered_lines']
            }

        return final_results

class AnalyzeCobertura(Main):
    """Coverage analysis script class"""
    coverage_dir = gh.resolve_path("tests/kcov-output")
    use_json = False

    def setup(self):
        """Check results of command line processing"""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        self.coverage_dir = self.get_parsed_option(COVERAGE_DIR, self.coverage_dir)
        self.use_json = self.get_parsed_option(JSON_OUTPUT, self.use_json)
        self.helper = CoverageHelper(self.coverage_dir)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def run_main_step(self):
        """Main processing step"""
        debug.trace(5, f"Script.run_main_step(): self={self}")
        coverage_results = self.helper.aggregate_coverage()
        sorted_results = sorted(coverage_results.items(), 
                                key=lambda x: x[1]['coverage'], 
                                reverse=True)

        # Calculate macro and micro scores
        macro_scores = []
        total_covered_lines = 0
        total_lines = 0

        detailed_results = []
        for idx, (script, data) in enumerate(sorted_results, start=1):
            extension = script.split('.')[-1] if '.' in script else 'N/A'
            coverage_pct = data['coverage'] * 100
            covered = data['covered_lines']
            total = data['total_lines']

            macro_scores.append(coverage_pct)
            total_covered_lines += covered
            total_lines += total
            
            detailed_results.append({
                "index": idx,
                "script": script,
                "extension": extension,
                "coverage_percentage": coverage_pct,
                "covered_lines": covered,
                "total_lines": total
            })

        # Compute Macro and Micro Scores
        macro_score = sum(macro_scores) / len(macro_scores) if macro_scores else 0
        micro_score = (total_covered_lines / total_lines) * 100 if total_lines > 0 else 0
        
        # Output results based on format preference
        if self.use_json:
            # JSON output format
            output = {
                "detailed_coverage": detailed_results,
                "summary": {
                    "macro_score": macro_score,
                    "micro_score": micro_score,
                    "total_covered_lines": total_covered_lines,
                    "total_lines": total_lines
                }
            }
            print(json.dumps(output, indent=2))
        else:
            # Standard text output format
            print("\nDetailed Coverage Summary (Aggregated):")
            print("-" * 120)
            print(f"{'#':<4} {'Script':<40} {'Extension':<10} {'Coverage':>10} {'Covered Lines':>15} {'Total Lines':>15}")
            print("-" * 120)
            
            for idx, (script, data) in enumerate(sorted_results, start=1):
                extension = script.split('.')[-1] if '.' in script else 'N/A'
                coverage_pct = data['coverage'] * 100
                covered = data['covered_lines']
                total = data['total_lines']
                
                print(f"{idx:<4} {gh.elide(script, 35):<40} {extension:<10} {coverage_pct:>9.1f}% {covered:>15d} {total:>15d}")
            
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
        text_options=[
            (COVERAGE_DIR, "Directory containing coverage reports")
        ],
        boolean_options=[
            (JSON_OUTPUT, "Output results in JSON format")
        ]
        )
    app.run()

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()