#! /usr/bin/env python

"""
Function coverage analysis script for processing Cobertura JSON reports and calculating test coverage per function.

Sample usage:
   {script} --cobertura=coverage/cobertura.json --functions=coverage/functions.json
"""

# Standard modules
import json
from collections import defaultdict

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

# Constants
TL = debug.TL
COBERTURA_JSON = "cobertura"
FUNCTIONS_JSON = "functions"

class FunctionCoverageHelper:
    """Helper class for processing function coverage data from Cobertura JSON reports"""
    
    def __init__(self, cobertura_path, functions_path):
        """Initializer: sets up file paths"""
        debug.trace(TL.VERBOSE, f"FunctionCoverageHelper.__init__(): self={self}")
        self.cobertura_path = cobertura_path
        self.functions_path = functions_path
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def load_json(self, file_path):
        """Loads JSON data from a file."""
        with open(file_path, "r") as f:
            return json.load(f)
    
    def get_covered_lines(self, cobertura_json):
        """Extracts covered lines from Cobertura JSON report."""
        covered_lines = set()
        packages = cobertura_json.get("cobertura_data", {}).get("coverage", {}).get("packages", {}).get("package", [])
        
        if isinstance(packages, dict):
            packages = [packages]
        
        for package in packages:
            classes = package.get("classes", {}).get("class", [])
            if isinstance(classes, dict):
                classes = [classes]
            
            for cls in classes:
                lines = cls.get("lines", {}).get("line", [])
                if isinstance(lines, dict):
                    lines = [lines]
                
                for line in lines:
                    if int(line["@hits"]) > 0:
                        covered_lines.add(int(line["@number"]))
        
        return covered_lines
    
    def compute_function_coverage(self, function_data, covered_lines):
        """Computes coverage percentage for each function."""
        function_coverage = {}

        for func, range_info in function_data.get("functions", {}).items():
            start, end = range_info["start"], range_info["end"]
            total_lines = (end - start) + 1
            covered = sum(1 for line in covered_lines if start <= line <= end)
            function_coverage[func] = (covered / total_lines) * 100 if total_lines > 0 else 0
        
        return function_coverage
    
    def analyze_function_coverage(self):
        """Compute function coverage using Cobertura and function data."""
        cobertura_data = self.load_json(self.cobertura_path)
        function_data = self.load_json(self.functions_path)
        covered_lines = self.get_covered_lines(cobertura_data)
        return self.compute_function_coverage(function_data, covered_lines)

class FunctionCoverage(Main):
    """Function coverage analysis script class"""
    cobertura_path = "coverage/cobertura.json"
    functions_path = "coverage/functions.json"

    def setup(self):
        """Initialize command-line options and helper instance."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        self.cobertura_path = self.get_parsed_option(COBERTURA_JSON, self.cobertura_path)
        self.functions_path = self.get_parsed_option(FUNCTIONS_JSON, self.functions_path)
        self.helper = FunctionCoverageHelper(self.cobertura_path, self.functions_path)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def run_main_step(self):
        """Main processing step"""
        debug.trace(5, f"Script.run_main_step(): self={self}")
        function_coverage = self.helper.analyze_function_coverage()
        
        print("\n📊 Function Coverage:")
        print("-" * 60)
        print(f"{'Function':<40} {'Coverage':>10}")
        print("-" * 60)

        for func, coverage in sorted(function_coverage.items(), key=lambda x: x[1], reverse=True):
            print(f"{gh.elide(func, 35):<40} {coverage:>9.2f}%")
        
        print("-" * 60)

def main():
    """Entry point"""
    app = FunctionCoverage(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        auto_help=True,
        text_options=[
            (COBERTURA_JSON, "Path to Cobertura JSON file"),
            (FUNCTIONS_JSON, "Path to extracted functions JSON file")
        ]
    )
    app.run()

if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()
