#! /usr/bin/env python

"""
Converts Cobertura reports to JSON, with the support of analyzing the reports.

Sample usage:
   {script} --input=path/to/cobertura.xml [--output=path/to/output.json] [--report]
"""

# Standard modules
import json
import xml.etree.ElementTree as ET
from collections import defaultdict
import xmltodict

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system

# Constants
TL = debug.TL
INPUT_PATH_ARG = "input"
OUTPUT_PATH_ARG = "output"
REPORT_ARG = "report"

class CoverageHelper:
    """Helper class for processing coverage data from Cobertura XML reports"""
    
    def __init__(self, input_path, output_path=None):
        """Initializer: sets up input and output paths"""
        debug.trace(TL.VERBOSE, f"CoverageHelper.__init__(): self={self}")
        self.input_path = input_path
        self.output_path = output_path
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def convert_and_analyze(self):
        """Convert XML to JSON and analyze coverage"""
        debug.trace(5, f"Converting and analyzing {self.input_path}")
        
        xml_data = system.read_file(self.input_path)
        cobertura_dict = xmltodict.parse(xml_data)
        
        # Parse with ElementTree for additional analysis
        tree = ET.parse(self.input_path)
        root = tree.getroot()
        coverage_data = self._process_coverage(root)
        uncovered_methods = self._find_uncovered_methods(root)
        
        # Combine results
        result = {
            'cobertura_data': cobertura_dict,
            'coverage_analysis': coverage_data,
            'uncovered_methods': uncovered_methods
        }
        
        if self.output_path:
            with open(self.output_path, 'w', encoding='utf-8') as json_file:
                json.dump(result, json_file, indent=4)
            print(f"Results written to: {self.output_path}")
        
        return result

    def _process_coverage(self, root):
        """Process coverage data from XML root"""
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
        
        return dict(coverage_data)

    def _find_uncovered_methods(self, root):
        """Find methods with zero coverage"""
        uncovered = []
        
        for class_elem in root.findall(".//class"):
            class_name = class_elem.get("name")
            methods = class_elem.findall(".//method")
            
            for method in methods:
                if float(method.get("line-rate", "0")) == 0:
                    uncovered.append({
                        "class": class_name,
                        "method": method.get("name"),
                        "signature": method.get("signature", "N/A")
                    })
        
        return uncovered

class AnalyzeCoverage(Main):
    """Coverage analysis script class"""
    
    def __init__(self, *args, **kwargs):
        """Initialize instance attributes"""
        self.helper = None
        self.input_path = ""
        self.output_path = None
        self.report_output = False
        super().__init__(*args, **kwargs)

    def setup(self):
        """Check results of command line processing"""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        self.input_path = self.get_parsed_option(INPUT_PATH_ARG, self.input_path)
        self.output_path = self.get_parsed_option(OUTPUT_PATH_ARG, self.output_path)
        self.report_output = self.get_parsed_option(REPORT_ARG, self.report_output)
        
        if not self.input_path:
            system.exit("Error: Input path is required")
        
        self.helper = CoverageHelper(self.input_path, self.output_path)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def print_formatted_output(self, result):
        """Print formatted coverage analysis results"""
        coverage_data = result['coverage_analysis']
        uncovered_methods = result['uncovered_methods']
        
        print("\nCoverage Analysis Summary:")
        print("=" * 80)
        
        total_covered = 0
        total_lines = 0
        all_rates = []
        
        for script, data in sorted(coverage_data.items()):
            coverage_pct = sum(data['rates']) / len(data['rates']) * 100
            all_rates.append(coverage_pct)
            total_covered += data['covered_lines']
            total_lines += data['total_lines']
            
            print(f"\nScript: {script}")
            print(f"Coverage Rate: {coverage_pct:.1f}%")
            print(f"Covered Lines: {data['covered_lines']}")
            print(f"Total Lines: {data['total_lines']}")
            print("-" * 40)
        
        if all_rates:  # Only print aggregates if we have data
            print("\nAggregate Metrics:")
            print("=" * 80)
            print(f"Average Coverage: {sum(all_rates) / len(all_rates):.1f}%")
            print(f"Total Coverage: {(total_covered / total_lines * 100):.1f}%")
            print(f"Total Covered Lines: {total_covered}")
            print(f"Total Lines: {total_lines}")
        
        if uncovered_methods:
            print("\nUncovered Methods:")
            print("=" * 80)
            for method in uncovered_methods:
                print(f"\nClass: {method['class']}")
                print(f"Method: {method['method']}")
                print(f"Signature: {method['signature']}")
        else:
            print("\nNo uncovered methods found!")

    def run_main_step(self):
        """Main processing step"""
        debug.trace(5, f"Script.run_main_step(): self={self}")
        result = self.helper.convert_and_analyze()
        
        if self.report_output:
            # Print formatted output
            self.print_formatted_output(result)
        else:
            # Print raw JSON to console
            print(json.dumps(result, indent=4))
            
def main():
    """Entry point"""
    app = AnalyzeCoverage(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        auto_help=True,
        boolean_options=[
            (REPORT_ARG, "Generate analyzed Cobertura reports")
        ],
        text_options=[
            (INPUT_PATH_ARG, "Path to input Cobertura XML file"),
            (OUTPUT_PATH_ARG, "Optional: Path for output JSON file (default: print to console)")
        ])
    app.run()

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()