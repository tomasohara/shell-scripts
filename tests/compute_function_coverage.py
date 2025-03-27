#! /usr/bin/env python

"""
Function coverage analysis script for processing Cobertura JSON reports and calculating test coverage per function.

Sample usage:
   {script} --cobertura=coverage/cobertura.json --functions=coverage/functions.json 
   [--json] [--sort=coverage|total_lines|covered_lines]
"""

# Standard modules
import json
import os
import sys
from collections import OrderedDict

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system

# Constants
TL = debug.TL
COBERTURA_JSON = "cobertura"
FUNCTIONS_JSON = "functions"
JSON_OUTPUT = "json"
SORT_OPTION = "sort"

class FunctionCoverageHelper:
    """Helper class for processing function coverage data from Cobertura JSON reports"""
    
    def __init__(self, cobertura_path, functions_path):
        """Initializer: sets up file paths"""
        debug.trace(TL.VERBOSE, f"FunctionCoverageHelper.__init__(): self={self}")
        self.cobertura_path = cobertura_path
        self.functions_path = functions_path
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def load_json(self, file_path):
        """Loads JSON data from a file with error handling."""
        try:
            if not os.path.exists(file_path):
                debug.trace(TL.ERROR, f"File not found: {file_path}")
                return None
                
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except json.JSONDecodeError as e:
            debug.trace(TL.ERROR, f"JSON parsing error in {file_path}: {e}")
            return None
        except IOError as e:
            debug.trace(TL.ERROR, f"Error loading {file_path}: {e}")
            return None
    
    def get_covered_lines(self, cobertura_json):
        """Extracts covered lines from Cobertura JSON report with improved parsing."""
        if not cobertura_json:
            return set()
            
        covered_lines = set()
        
        # Handle different JSON structures that might be present
        # First try the standard structure
        packages = cobertura_json.get("cobertura_data", {}).get("coverage", {}).get("packages", {}).get("package", [])
        
        # If packages is not found, try alternate structure
        if not packages and "packages" in cobertura_json:
            packages = cobertura_json.get("packages", [])
        
        # Ensure packages is a list
        if isinstance(packages, dict):
            packages = [packages]
        
        for package in packages:
            # Get classes, handling different possible structures
            classes = None
            if "classes" in package:
                classes = package.get("classes", {})
                if isinstance(classes, dict):
                    classes = classes.get("class", [])
            elif "class" in package:
                classes = package.get("class", [])
            
            # Ensure classes is a list
            if isinstance(classes, dict):
                classes = [classes]
                
            if not classes:
                continue
            
            for cls in classes:
                # Get lines, handling different possible structures
                lines = None
                if "lines" in cls:
                    lines = cls.get("lines", {})
                    if isinstance(lines, dict):
                        lines = lines.get("line", [])
                elif "line" in cls:
                    lines = cls.get("line", [])
                
                # Ensure lines is a list
                if isinstance(lines, dict):
                    lines = [lines]
                    
                if not lines:
                    continue
                
                for line in lines:
                    # Handle different attribute formats
                    hits = line.get("@hits", line.get("hits", 0))
                    number = line.get("@number", line.get("number", -1))
                    
                    # Convert to appropriate types
                    try:
                        hits = int(hits)
                        number = int(number)
                        
                        if hits > 0 and number > 0:
                            covered_lines.add(number)
                    except (ValueError, TypeError):
                        continue
        
        return covered_lines
    
    def compute_function_coverage(self, function_data, covered_lines):
        """Computes coverage percentage, covered lines, and total lines for each function."""
        function_coverage = {}

        if not function_data or "functions" not in function_data:
            debug.trace(TL.ERROR, "Invalid function data format")
            return function_coverage

        for func, range_info in function_data.get("functions", {}).items():
            if not isinstance(range_info, dict) or "start" not in range_info or "end" not in range_info:
                debug.trace(TL.ERROR, f"Invalid range info for function {func}")
                continue
                
            start, end = range_info["start"], range_info["end"]
            
            # Ensure start and end are integers
            try:
                start = int(start)
                end = int(end)
            except (ValueError, TypeError):
                debug.trace(TL.ERROR, f"Invalid line range for function {func}: {start}-{end}")
                continue
                
            total_lines = (end - start) + 1
            covered_func_lines = [line for line in covered_lines if start <= line <= end]
            covered = len(covered_func_lines)
            function_coverage[func] = {
                "coverage_percentage": (covered / total_lines) * 100 if total_lines > 0 else 0,
                "covered_lines": covered,
                "total_lines": total_lines,
                "covered_lines_list": covered_func_lines
            }
        
        return function_coverage
    
    def analyze_function_coverage(self):
        """Compute function coverage using Cobertura and function data."""
        cobertura_data = self.load_json(self.cobertura_path)
        function_data = self.load_json(self.functions_path)
        
        if not cobertura_data:
            debug.trace(TL.ERROR, f"Failed to load Cobertura data from {self.cobertura_path}")
            return {}
            
        if not function_data:
            debug.trace(TL.ERROR, f"Failed to load function data from {self.functions_path}")
            return {}
            
        covered_lines = self.get_covered_lines(cobertura_data)
        return self.compute_function_coverage(function_data, covered_lines)

class FunctionCoverage(Main):
    """Function coverage analysis script class"""
    def __init__(self, *args, **kwargs):
        """Initialize instance variables"""
        super().__init__(*args, **kwargs)
        self.cobertura_path = ""
        self.functions_path = ""
        self.json_output = False
        self.sort_option = "coverage"
        self.helper = None

    def setup(self):
        """Initialize command-line options and helper instance."""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        self.cobertura_path = self.get_parsed_option(COBERTURA_JSON, self.cobertura_path)
        self.functions_path = self.get_parsed_option(FUNCTIONS_JSON, self.functions_path)
        self.json_output = self.get_parsed_option(JSON_OUTPUT, self.json_output)
        self.sort_option = self.get_parsed_option(SORT_OPTION, self.sort_option)
        self.helper = FunctionCoverageHelper(self.cobertura_path, self.functions_path)
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def sort_function_coverage(self, function_coverage):
        """Sort function coverage based on the selected option."""
        if self.sort_option == "total_lines":
            return OrderedDict(sorted(function_coverage.items(), 
                                      key=lambda x: x[1]['total_lines'], 
                                      reverse=True))
        if self.sort_option == "covered_lines":
            return OrderedDict(sorted(function_coverage.items(), 
                                      key=lambda x: x[1]['covered_lines'], 
                                      reverse=True))
        
        return OrderedDict(sorted(function_coverage.items(), 
                                  key=lambda x: x[1]['coverage_percentage'], 
                                  reverse=True))
    
    def calculate_scores(self, function_coverage):
        """Calculate micro and macro scores."""
        total_total_lines = 0
        total_covered_lines = 0
        
        # Macro score: Average of individual function coverage percentages
        macro_scores = [details['coverage_percentage'] for details in function_coverage.values()]
        macro_score = sum(macro_scores) / len(macro_scores) if macro_scores else 0
        
        # Micro score: Total covered lines / total lines
        for details in function_coverage.values():
            total_total_lines += details['total_lines']
            total_covered_lines += details['covered_lines']
        
        micro_score = (total_covered_lines / total_total_lines) * 100 if total_total_lines > 0 else 0
        
        return {
            "total_lines": total_total_lines,
            "covered_lines": total_covered_lines,
            "micro_score": micro_score,
            "macro_score": macro_score
        }
    
    def run_main_step(self):
        """Main processing step"""
        debug.trace(5, f"Script.run_main_step(): self={self}")
        function_coverage = self.helper.analyze_function_coverage()
        
        if not function_coverage:
            print("\n⚠️ No function coverage data was generated. Please check your input files.")
            return
        
        # Sort function coverage
        sorted_function_coverage = self.sort_function_coverage(function_coverage)
        
        # Calculate overall scores
        scores = self.calculate_scores(function_coverage)
        
        if self.json_output:
            # Output as JSON
            output_data = {
                "function_coverage": sorted_function_coverage,
                "overall_scores": scores
            }
            json.dump(output_data, sys.stdout, indent=2)
        else:
            # Pretty print tabular output
            print("\n📊 Function Coverage:")
            print("-" * 90)
            print(f"{'Function':<40} {'Coverage %':>10} {'Covered Lines':>15} {'Total Lines':>12}")
            print("-" * 90)

            for func, details in sorted_function_coverage.items():
                print(f"{gh.elide(func, 35):<40} {details['coverage_percentage']:>9.2f}% {details['covered_lines']:>15} {details['total_lines']:>12}")
            
            # Total scores row
            print("-" * 90)
            print(f"{'TOTAL':<40} {scores['micro_score']:>9.2f}% {scores['covered_lines']:>15} {scores['total_lines']:>12}")
            print("-" * 90)
            
            # Detailed breakdown below the table
            
            print("\n📈 Detailed Scores:")
            print(f"Micro Score (Covered/Total):  {scores['micro_score']:0.2f}%")
            print(f"Macro Score (Avg Coverage):   {scores['macro_score']:0.2f}%")

def main():
    """Entry point"""
    app = FunctionCoverage(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        auto_help=True,
        text_options=[
            (COBERTURA_JSON, "Path to Cobertura JSON file"),
            (FUNCTIONS_JSON, "Path to extracted functions JSON file"),
            (SORT_OPTION, "Sort by: coverage (default), total_lines, or covered_lines")
        ],
        boolean_options=[
            (JSON_OUTPUT, "Output results in JSON format (default: False)")
        ]
    )
    app.run()

if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()