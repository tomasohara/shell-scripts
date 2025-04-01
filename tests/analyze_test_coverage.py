#! /usr/bin/python

"""
Test Coverage Extraction Pipeline

This script processes a Bash script (`script.bash`) and a Jupyter Notebook (`file.ipynb`)
to extract test coverage information using a multi-stage pipeline.

### **Pipeline Overview**

#### **A. Processing `script.bash`**
(Converts Bash script into a structured, testable format)
1. **Convert to multiline format**  
   - `tests/bash_to_multiline.py` → Generates `multiline.bash`
2. **Extract macros from Bash script**  
   - `tests/extract_bash_macros.py` → Generates `multiline_macro.json`
3. **(Optional) Additional Bash processing**

#### **B. Processing `file.ipynb` (Parallel to A)**
(Converts Jupyter Notebook into a testable batspp script)
1. **Convert Notebook to batspp format**  
   - `jupyter_to_batspp` → Converts `file.ipynb` → `file.batspp`
2. **(Alternative) Convert directly to Bats**  
   - `batspp / simple_batspp.py` → Converts `file.ipynb` → `file.bats`
3. **Convert `file.batspp` to standard Bats format**  
   - `batspp / simple_batspp.py` → Converts `file.batspp` → `file.bats`
4. **Merge sources and generate final Bats file**  
   - `batspp (with source)` → Uses `multiline.bash`, `file.batspp` → Produces `file.bats`
5. **Run tests and collect coverage data**  
   - `kcov` → Runs tests in `file.bats` and generates `kcov-output/file/*`

#### **C. Generate Cobertura Report (Sequential Step)**
(Converts kcov coverage output into Cobertura JSON format)
6. **Convert kcov output to Cobertura format**  
   - `tests/cobertura_to_json` → Converts `kcov-output/file/bats/cobertura.xml` → `cobertura.json`

#### **D. Generate Final Reports (Sequential Step)**
(Processes coverage data and generates summary reports)
7. **Compute function-level coverage**  
   - `tests/compute_function_coverage.py` → Analyzes `cobertura.json` and `multiline_macro.json`, providing function coverage rankings
8. **Perform additional coverage analysis**  
   - `tests/analyze_cobertura.py` → Uses `kcov-output` for deeper insights

### **Execution Notes**
- **C starts only after A & B complete.**
- **D depends on the output from C.**

This ensures efficient processing while maintaining dependencies between steps.
"""

# Standard modules
import os
import datetime
import json

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

## Helper modules
# import bash_to_multiline as bash2multiline
# import extract_bash_macros as extract_macros
# import jupyter_to_batspp as jupyter2batspp
# import compute_function_coverage
# import analyze_cobertura 

# TODO: Use resolved paths for individual working scripts

debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

# Argument Options
BASH_SOURCE_ARG = "bash-source"
NOTEBOOK_ARG = "notebook"
INTERMEDIATE_OUTPUT_ARG = "intermediate-output"
ALT_RESULT_ARG = "alt-result"
OUTPUT_ARG = "output" 
SKIP_ARG = "skip"
DRY_RUN_ARG = "dry-run"
SIMPLE_BATSPP_ARG = "simple-batspp"

# Constants
TL = debug.TL
DEFAULT_TIMEOUT = 300  # 5 minutes timeout for commands

# Environment Variables
KCOV_INCLUDE_PATTERN = os.environ.get("KCOV_INCLUDE_PATTERN", "")
BATSPP_PATH = os.environ.get("BATSPP_PATH", "batspp")
JUPYTER_TO_BATSPP_PATH = os.environ.get("JUPYTER_TO_BATSPP_PATH", "jupyter_to_batspp.py")
# JSON_OUTPUT = system.env_options

## Helper Script
class AnalyzeTestCoverageHelper:
    """Helper class for Analyze Test Coverage"""

    def __init__(self, bash_source_path, notebook_path, intermediate_output_dir=None, dry_run=False):
        """Parameterized constructor"""
        debug.trace(TL.VERBOSE, f"AnalyzeTestCoverageHelper.__init__(): self={self}")
        self.bash_source_path = bash_source_path
        self.notebook_path = notebook_path
        self.temp_dir = system.TEMP_DIR + f'_{datetime.datetime.now().strftime("%y%m%d%H%M%S")}'
        self.dry_run = dry_run
        
        # Create temp directory if it doesn't exist
        if not os.path.exists(self.temp_dir):
            os.makedirs(self.temp_dir)
            
        # Create kcov output directory
        self.kcov_output_dir = f"{self.temp_dir}/kcov-output"
        if not os.path.exists(self.kcov_output_dir):
            os.makedirs(self.kcov_output_dir)
            
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    ## Pipeline Steps for Bash Source 
    def _convert_bash_to_multiline(self, bash_source_path):
        debug.trace(TL.VERBOSE, f"Converting to multiline format {bash_source_path}")
        
        output_path = f"{self.temp_dir}/{gh.basename(bash_source_path, extension='.bash')}_multiline.bash"
        full_command = f"python tests/bash_to_multiline.py {bash_source_path} > {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(TL.BASIC, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        result = gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not os.path.exists(output_path):
            debug.warning(f"Expected output file not created: {output_path}")
            
        return output_path

    def _extract_bash_macros(self, bash_source_path):
        """Extract macros from the Bash script"""
        debug.trace(TL.VERBOSE, f"Extracting macros from {bash_source_path}")
        
        output_path = f"{self.temp_dir}/{gh.basename(bash_source_path, extension='.bash')}_macros.json"
        full_command = f"python tests/extract_bash_macros.py {bash_source_path} --json > {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(TL.BASIC, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        result = gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not os.path.exists(output_path):
            debug.warning(f"Expected output file not created: {output_path}")
            
        return output_path

    ## Pipeline Steps for Jupyter Notebook
    def _convert_notebook_to_batspp(self, notebook_path, use_simple_batspp=False):
        """Convert Jupyter Notebook to batspp format"""
        debug.trace(TL.VERBOSE, f"Converting to batspp format {notebook_path}")
        
        command = "python simple_batspp.py" if use_simple_batspp else f"python {JUPYTER_TO_BATSPP_PATH}"
        output_path = f"{self.temp_dir}/{gh.basename(notebook_path, extension='.ipynb')}.batspp"
        full_command = f"{command} {notebook_path} > {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(TL.BASIC, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        result = gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not os.path.exists(output_path):
            debug.warning(f"Expected output file not created: {output_path}")
            
        return output_path
    
    def _convert_batspp_to_bats(self, batspp_path, bash_source_path, use_simple_batspp=False):
        """Convert batspp script to standard Bats format"""
        debug.trace(TL.VERBOSE, f"Converting to Bats format {batspp_path}")
        
        command = "python simple_batspp.py" if use_simple_batspp else BATSPP_PATH
        output_path = f"{self.temp_dir}/{gh.basename(batspp_path, extension='.batspp')}.bats"
        full_command = f"{command} {batspp_path} --source {bash_source_path} --save {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(TL.BASIC, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        result = gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not os.path.exists(output_path):
            debug.warning(f"Expected output file not created: {output_path}")
            
        return output_path

    def _generate_kcov_output(self, bats_path, bash_source_path):
        """Generate kcov output from Bats tests"""
        debug.trace(TL.VERBOSE, f"Generating kcov output from {bats_path}")
        
        filename = gh.basename(bats_path, extension='.bats')
        output_path = f"{self.kcov_output_dir}/{filename}"        
        
        # Create output directory if it doesn't exist
        if not os.path.exists(self.kcov_output_dir) and not self.dry_run:
            os.makedirs(self.kcov_output_dir)
            
        include_pattern = KCOV_INCLUDE_PATTERN or bash_source_path
        full_command = f"kcov {output_path} bats {bats_path}"

        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(TL.BASIC, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        result = gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not os.path.exists(output_path):
            debug.trace(5, f"Expected output directory not created: {output_path}")
            
        return output_path
    
    def _extract_cobertura_coverage(self, kcov_output_path):
        """Convert kcov output to Cobertura format"""
        debug.trace(TL.VERBOSE, f"Extracting Cobertura coverage from {kcov_output_path}")
        
        cobertura_path = f"{kcov_output_path}/bats/cobertura.xml"
        if not os.path.exists(cobertura_path) and not self.dry_run:
            debug.trace(5, f"Cobertura file not found at {cobertura_path}")
            cobertura_path = f"{kcov_output_path}/bats/coverage.xml"  # Fallback
            
        output_path = f"{self.temp_dir}/{gh.basename(kcov_output_path)}_cobertura.json"
        full_command = f"python tests/cobertura_to_json.py --input {cobertura_path} --output {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(TL.BASIC, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        result = gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not os.path.exists(output_path):
            debug.warning(f"Expected output file not created: {output_path}")
            
        return output_path
    
    ## Pipeline Steps for Function Coverage
    def _generate_function_coverage(self, cobertura_path, macros_path, json_output=False):
        """Generate function-level coverage report"""
        debug.trace(TL.VERBOSE, f"Generating function coverage from {cobertura_path}")
        
        output_suffix = "_function_coverage.json" if json_output else "_function_coverage.txt"
        output_path = f"{self.temp_dir}/{gh.basename(cobertura_path, extension='.json')}{output_suffix}"
        
        command = f"python tests/compute_function_coverage.py --cobertura {cobertura_path} --functions {macros_path}"
        if json_output:
            command += " --json"
        
        full_command = f"{command} > {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(TL.BASIC, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        result = gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not os.path.exists(output_path):
            debug.warning(f"Expected output file not created: {output_path}")
            
        return output_path
    
    def _generate_alternative_function_coverage(self, kcov_output_path):
        """Generate alternative function coverage report"""
        debug.trace(TL.VERBOSE, f"Generating alternative function coverage from {kcov_output_path}")
        
        output_path = f"{self.temp_dir}/{gh.basename(kcov_output_path)}_alt_coverage.txt"
        full_command = f"python tests/analyze_cobertura.py {kcov_output_path} > {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(TL.BASIC, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        result = gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not os.path.exists(output_path):
            debug.warning(f"Expected output file not created: {output_path}")
            
        return output_path

    def run_pipeline(self, alternate_result=False, skip_steps=None, use_simple_batspp=False):
        """Run the entire pipeline for test coverage extraction.
        
        Args:
            alternate_result: Whether to generate alternative function coverage
            skip_steps: List of step names to skip (e.g. ["bash", "notebook"])
            use_simple_batspp: Whether to use simple_batspp.py instead of batspp
            
        Returns:
            Dictionary with paths to generated files
        """
        debug.trace(TL.VERBOSE, "Running the test coverage extraction pipeline")
        skip_steps = skip_steps or []
        results = {}

        # Process bash
        if "bash" not in skip_steps:
            multiline_bash = self._convert_bash_to_multiline(self.bash_source_path)
            bash_macros = self._extract_bash_macros(self.bash_source_path)
        else:
            debug.trace(TL.BASIC, "Skipping bash processing")
            multiline_bash = None
            bash_macros = None
            
        # Process notebook
        if "notebook" not in skip_steps:
            batspp_script = self._convert_notebook_to_batspp(self.notebook_path, use_simple_batspp)
            bats_script = self._convert_batspp_to_bats(batspp_script, multiline_bash, use_simple_batspp)
        else:
            debug.trace(TL.BASIC, "Skipping notebook processing")
            batspp_script = None
            bats_script = None
            
        # Process coverage
        if "coverage" not in skip_steps:
            kcov_output = self._generate_kcov_output(bats_script, multiline_bash)
        else:
            debug.trace(TL.BASIC, "Skipping coverage generation")
            kcov_output = None
            
        # Process cobertura
        if "cobertura" not in skip_steps:
            cobertura_coverage = self._extract_cobertura_coverage(kcov_output)
        else:
            debug.trace(TL.BASIC, "Skipping cobertura extraction")
            cobertura_coverage = None
            
        # Process function coverage
        if "function" not in skip_steps:
            func_coverage = self._generate_function_coverage(cobertura_coverage, bash_macros, json_output=False)
            
            # Generate alternative function coverage if requested
            if alternate_result and kcov_output:
                alt_coverage = self._generate_alternative_function_coverage(kcov_output)
            else:
                alt_coverage = None
        else:
            debug.trace(TL.BASIC, "Skipping function coverage generation")
            func_coverage = None
            alt_coverage = None
        
        # Collect results
        results = {
            "multiline_bash": multiline_bash,
            "bash_macros": bash_macros,
            "batspp_script": batspp_script,
            "bats_script": bats_script,
            "kcov_output": kcov_output,
            "cobertura_coverage": cobertura_coverage,
            "function_coverage": func_coverage,
            "alt_function_coverage": alt_coverage
        }
        
        debug.trace(TL.VERBOSE, f"Pipeline completed with results: {json.dumps(results, indent=2)}")
        return results

## Main Script
class AnalyzeTestCoverageScript(Main):
    """Input processing class for handling command-line arguments and processing input lines."""

    def setup(self):
        """Extract and initialize command-line arguments."""
        debug.trace(TL.VERBOSE, f"AnalyzeTestCoverageScript.setup(): self={self}")
        
        # Get required arguments
        self.bash_source = self.get_parsed_argument(BASH_SOURCE_ARG)
        self.notebook = self.get_parsed_argument(NOTEBOOK_ARG)
        
        # Get optional arguments with defaults
        self.intermediate_output = self.get_parsed_option(INTERMEDIATE_OUTPUT_ARG, system.TEMP_DIR)
        self.alt_result = self.get_parsed_option(ALT_RESULT_ARG, False)
        self.output = self.get_parsed_option(OUTPUT_ARG, None)
        self.skip = self.get_parsed_option(SKIP_ARG, "").split(",")
        self.dry_run = self.get_parsed_option(DRY_RUN_ARG, False)
        self.simple_batspp = self.get_parsed_option(SIMPLE_BATSPP_ARG, False)
        
        # Validate arguments
        if not self.bash_source:
            debug.fatal_error(f"Required argument missing: {BASH_SOURCE_ARG}")
        if not os.path.exists(self.bash_source):
            debug.fatal_error(f"Bash source file not found: {self.bash_source}")
            
        if not self.notebook:
            debug.fatal_error(f"Required argument missing: {NOTEBOOK_ARG}")
        if not os.path.exists(self.notebook):
            debug.fatal_error(f"Notebook file not found: {self.notebook}")
            
        # Initialize helper
        self.helper = AnalyzeTestCoverageHelper(
            bash_source_path=self.bash_source,
            notebook_path=self.notebook,
            intermediate_output_dir=self.intermediate_output,
            dry_run=self.dry_run
        )
        
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def process_line(self, line):
        """Processes a line of input based on the provided arguments."""
        debug.trace_fmtd(TL.QUITE_DETAILED, "Script.process_line({l})", l=line)
        debug.trace(3, f"Ignoring line ({self.line_num}): {line}")

    def run_main_app(self):
        """Run the main application logic"""
        debug.trace(TL.VERBOSE, "Running main application logic")
        
        # Run the pipeline
        results = self.helper.run_pipeline(
            alternate_result=self.alt_result,
            skip_steps=self.skip,
            use_simple_batspp=self.simple_batspp
        )
        
        # Output results
        if self.output:
            with open(self.output, 'w') as f:
                json.dump(results, f, indent=2)
        else:
            # Print the function coverage results to stdout
            if results["function_coverage"] and os.path.exists(results["function_coverage"]):
                print(system.read_file(results["function_coverage"]))
            elif results["alt_function_coverage"] and os.path.exists(results["alt_function_coverage"]):
                print(system.read_file(results["alt_function_coverage"]))
            else:
                print(json.dumps(results, indent=2))


## Main
def main():
    """Entry point for the script."""
    app = AnalyzeTestCoverageScript(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,        # Skip line-by-line processing for this application
        manual_input=False,     # No manual input needed
        positional_arguments=[
            (BASH_SOURCE_ARG, "Path to the Bash script to analyze"),
            (NOTEBOOK_ARG, "Path to the Jupyter notebook to analyze")
        ],
        boolean_options=[
            (ALT_RESULT_ARG, "Generate alternative function coverage"),
            (DRY_RUN_ARG, "Print commands without executing them"),
            (SIMPLE_BATSPP_ARG, "Use simple_batspp.py instead of batspp")
        ],
        string_options=[
            (INTERMEDIATE_OUTPUT_ARG, "Directory for intermediate output files"),
            (OUTPUT_ARG, "Path to output JSON results file"),
            (SKIP_ARG, "Comma-separated list of steps to skip (bash,notebook,coverage,cobertura,function)")
        ]
    )
    app.run()
    
    # Override run method to execute our main application logic
    app.run_main_app()

    # Ensure no unprocessed TODO placeholders remain
    # debug.assertion(not any(my_re.search(r"^TODO_", m, my_re) for m in dir(app)))

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()