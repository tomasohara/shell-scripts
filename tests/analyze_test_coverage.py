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
import sys
import datetime
import json

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system
from mezcla import file_utils as fu

# TODO: Use resolved paths for individual working scripts
debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

# Argument Options
BASH_SOURCE_ARG = "bash-source"
NOTEBOOK_ARG = "notebook"
INTERMEDIATE_OUTPUT_ARG = "intermediate-output"
ALT_RESULT_ARG = "alt-result"
ALT_ARG = "alt"  # Adding a shorter alternative
OUTPUT_ARG = "output" 
SKIP_ARG = "skip"
DRY_RUN_ARG = "dry-run"
SIMPLE_BATSPP_ARG = "simple-batspp"

# Constants
TL = debug.TL
DEFAULT_TIMEOUT = 300  # 5 minutes timeout for commands

# Environment Variables
KCOV_INCLUDE_PATTERN = system.getenv_text("KCOV_INCLUDE_PATTERN", "", description="Pattern for kcov --include")
BATSPP_PATH = system.getenv_text("BATSPP_PATH", "~/.local/bin/batspp", description="Path to batspp library")
JUPYTER_TO_BATSPP_PATH = system.getenv_text("JUPYTER_TO_BATSPP_PATH", "jupyter_to_batspp.py", description="Path to jupyter_to_batspp.py")
JSON_OUTPUT = system.getenv_bool("JSON_OUTPUT", False, description="Enable JSON output for function coverage")
KCOV_OUTPUT_DIR = system.getenv_text("KCOV_OUTPUT_DIR", "kcov-output", description="Directory for kcov output")
RESULT_SORT_ORDER = system.getenv_text("SORT_ORDER", "coverage", description="Sort order for function coverage results (coverage/total_lines/covered_lines)")

## Helper Script
class AnalyzeTestCoverageHelper:
    """Helper class for Analyze Test Coverage"""

    def __init__(self, bash_source_path, notebook_path, intermediate_output_dir=None, dry_run=False):
        """Parameterized constructor"""
        debug.trace(TL.VERBOSE, f"AnalyzeTestCoverageHelper.__init__(): self={self}")
        self.bash_source_path = bash_source_path
        self.notebook_path = notebook_path
        self.intermediate_output_dir = intermediate_output_dir
        self.temp_dir = intermediate_output_dir or gh.form_path(system.TEMP_DIR, f'tmp_{datetime.datetime.now().strftime("%y%m%d%H%M%S")}')
        self.dry_run = dry_run

        # Create temp directory if it doesn't exist
        if not system.file_exists(self.temp_dir):
            debug.trace(TL.VERBOSE, f"Creating temp directory: {self.temp_dir}")
            gh.full_mkdir(self.temp_dir)

        # Create kcov output directory
        self.kcov_output_dir = gh.form_path(self.temp_dir, "kcov-output")
        if not system.file_exists(self.kcov_output_dir):
            debug.trace(TL.VERBOSE, f"Creating kcov output directory: {self.kcov_output_dir}")
            gh.full_mkdir(self.kcov_output_dir)
            
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def _ensure_dir_exists(self, filepath):
        """Ensure directory for the given file path exists"""
        directory = gh.dir_path(filepath)
        if directory and not system.file_exists(directory):
            debug.trace(TL.VERBOSE, f"Creating directory: {directory}")
            gh.full_mkdir(directory)
        return filepath

    ## Pipeline Steps for Bash Source 
    def _convert_bash_to_multiline(self, bash_source_path):
        debug.trace(TL.VERBOSE, f"Converting to multiline format {bash_source_path}")
        
        output_path = gh.form_path(self.temp_dir, f"{gh.basename(bash_source_path, extension='.bash')}_multiline.bash")
        self._ensure_dir_exists(output_path)
        full_command = f"python tests/bash_to_multiline.py {bash_source_path} > {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(4, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not system.file_exists(output_path):
            debug.trace_exception(4, f"Expected output file not created: {output_path}")
            
        return output_path

    def _extract_bash_macros(self, bash_source_path):
        """Extract macros from the Bash script"""
        debug.trace(TL.VERBOSE, f"Extracting macros from {bash_source_path}")
        
        output_path = gh.form_path(self.temp_dir, f"{gh.basename(bash_source_path, extension='.bash')}_macros.json")
        self._ensure_dir_exists(output_path)
        full_command = f"python tests/extract_bash_macros.py {bash_source_path} --json > {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(4, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not system.file_exists(output_path):
            debug.trace_exception(4, f"Expected output file not created: {output_path}")
            
        return output_path

    ## Pipeline Steps for Jupyter Notebook
    def _convert_notebook_to_batspp(self, notebook_path, use_simple_batspp=False):
        """Convert Jupyter Notebook to batspp format"""
        debug.trace(TL.VERBOSE, f"Converting to batspp format {notebook_path}")
        
        command = "python simple_batspp.py" if use_simple_batspp else f"python {JUPYTER_TO_BATSPP_PATH}"
        output_path = gh.form_path(self.temp_dir, f"{gh.basename(notebook_path, extension='.ipynb')}.batspp")
        self._ensure_dir_exists(output_path)
        full_command = f"{command} {notebook_path} > {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(4, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not system.file_exists(output_path):
            debug.trace_exception(5, f"Expected output file not created: {output_path}")
            
        return output_path
    
    def _convert_batspp_to_bats(self, batspp_path, bash_source_path, use_simple_batspp=False):
        """Convert batspp script to standard Bats format"""
        debug.trace(TL.VERBOSE, f"Converting to Bats format {batspp_path}")
        
        command = "python simple_batspp.py" if use_simple_batspp else BATSPP_PATH
        output_path = gh.form_path(self.temp_dir, f"{gh.basename(batspp_path, extension='.batspp')}.bats")
        self._ensure_dir_exists(output_path)
        full_command = f"{command} {batspp_path} --source {bash_source_path} --save {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(4, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        if not system.file_exists(batspp_path):
            debug.trace_exception(4, f"Input file not found: {batspp_path}")
            if not self.dry_run:
                # Create an empty file to allow pipeline to continue
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write("# Empty BATS file (created as fallback)\n")
                return output_path
        
        gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not system.file_exists(output_path):
            debug.trace_exception(5, f"Expected output file not created: {output_path}")
            if not self.dry_run:
                # Create an empty file to allow pipeline to continue
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write("# Empty BATS file (created as fallback)\n")
                
        return output_path

    def _generate_kcov_output(self, bats_path, bash_source_path):
        """Generate kcov output from Bats tests"""
        debug.trace(TL.VERBOSE, f"Generating kcov output from {bats_path}")
        
        filename = gh.basename(bats_path, extension='.bats')
        output_path = gh.form_path(self.kcov_output_dir, filename)        
        self._ensure_dir_exists(output_path)
        
        # Store include_pattern but use it in the command
        include_pattern = KCOV_INCLUDE_PATTERN or bash_source_path
        full_command = f"kcov {output_path} bats {bats_path}"

        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(4, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        if not system.file_exists(bats_path):
            debug.trace_exception(4, f"Input file not found: {bats_path}")
            # Create minimal output directory structure
            gh.full_mkdir(gh.form_path(output_path, "bats"))
            return output_path
        
        gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not system.file_exists(output_path):
            debug.trace(5, f"Expected output directory not created: {output_path}")
            # Create minimal output directory structure
            gh.full_mkdir(gh.form_path(output_path, "bats"))
            
        return output_path
    
    def _extract_cobertura_coverage(self, kcov_output_path):
        """Convert kcov output to Cobertura format"""
        debug.trace(TL.VERBOSE, f"Extracting Cobertura coverage from {kcov_output_path}")
        
        cobertura_path = gh.form_path(kcov_output_path, "bats", "cobertura.xml")
        fallback_cobertura_path = gh.form_path(kcov_output_path, "bats", "coverage.xml")
        
        if not system.file_exists(cobertura_path) and not self.dry_run:
            debug.trace(5, f"Cobertura file not found at {cobertura_path}")
            cobertura_path = fallback_cobertura_path  # Fallback
            
            # Create empty file if it doesn't exist to allow pipeline to continue
            if not system.file_exists(cobertura_path):
                debug.trace(5, f"Creating empty cobertura file at {cobertura_path}")
                self._ensure_dir_exists(cobertura_path)
                with open(cobertura_path, 'w', encoding='utf-8') as f:
                    f.write('<?xml version="1.0" ?><coverage></coverage>')
            
        output_path = gh.form_path(self.temp_dir, f"{gh.basename(kcov_output_path)}_cobertura.json")
        self._ensure_dir_exists(output_path)
        full_command = f"python tests/cobertura_to_json.py --input {cobertura_path} --output {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(4, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not system.file_exists(output_path):
            debug.trace_exception(5, f"Expected output file not created: {output_path}")
            # Create empty JSON file to allow pipeline to continue
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('{"coverage": {}}')
            
        return output_path
    
    ## Pipeline Steps for Function Coverage
    def _generate_function_coverage(self, cobertura_path, macros_path, json_output=False):
        """Generate function-level coverage report"""
        debug.trace(TL.VERBOSE, f"Generating function coverage from {cobertura_path}")
        
        output_suffix = "_function_coverage.json" if json_output else "_function_coverage.txt"
        output_path = gh.form_path(self.temp_dir, f"{gh.basename(cobertura_path, extension='.json')}{output_suffix}")
        self._ensure_dir_exists(output_path)
        
        command = f"python tests/compute_function_coverage.py --cobertura {cobertura_path} --functions {macros_path} --sort {RESULT_SORT_ORDER}"
        if json_output:
            command += " --json"
        
        full_command = f"{command} > {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(4, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        if not system.file_exists(cobertura_path) or not system.file_exists(macros_path):
            debug.trace_exception(4, f"Input file(s) not found: cobertura={cobertura_path}, macros={macros_path}")
            # Create empty output file
            with open(output_path, 'w', encoding='utf-8') as f:
                if json_output:
                    f.write('{"functions": []}')
                else:
                    f.write("No function coverage data available.\n")
            return output_path
        
        gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not system.file_exists(output_path):
            debug.trace_exception(5, f"Expected output file not created: {output_path}")
            # Create empty output file
            with open(output_path, 'w', encoding='utf-8') as f:
                if json_output:
                    f.write('{"functions": []}')
                else:
                    f.write("No function coverage data available.\n")
            
        return output_path
    
    ## TODO: Rework with the file not exist logic to "make more sense"
    def _generate_alternative_function_coverage(self, kcov_output_path, json_output=False):
        """Generate alternative function coverage report"""
        debug.trace(TL.VERBOSE, f"Generating alternative function coverage from {kcov_output_path}")
        
        output_suffix = "_alt_coverage.json" if json_output else "_alt_coverage.txt"
        output_path = gh.form_path(self.temp_dir, f"{gh.basename(kcov_output_path)}{output_suffix}")
        self._ensure_dir_exists(output_path)
        
        json_flag = "--json" if json_output else ""
        full_command = f"python tests/analyze_cobertura.py --coverage-dir {kcov_output_path} {json_flag} > {output_path}"
        
        debug.trace(TL.VERBOSE, f"Running command: {full_command}")
        
        if self.dry_run:
            debug.trace(4, f"[DRY RUN] Would execute: {full_command}")
            return output_path
        
        if not system.file_exists(kcov_output_path):
            debug.trace_exception(4, f"Input directory not found: {kcov_output_path}")
            # Create empty output file with appropriate format
            with open(output_path, 'w', encoding='utf-8') as f:
                if json_output:
                    f.write('{"error": "kcov_output_dir not found", "path": "' + kcov_output_path + '"}')
                else:
                    f.write(f"kcov_output_dir not found: {kcov_output_path}")
            return output_path
        
        gh.run(full_command, timeout=DEFAULT_TIMEOUT)
        
        if not system.file_exists(output_path):
            debug.trace_exception(5, f"Expected output file not created: {output_path}")
            # Create empty output file with appropriate format
            with open(output_path, 'w', encoding='utf-8') as f:
                if json_output:
                    f.write('{"error": "output_path not found", "path": "' + output_path + '"}')
                else:
                    f.write(f"output_path not found: {output_path}")
            
        return output_path

    def run_pipeline(self, skip_steps=None, use_simple_batspp=False):
        """Run the entire pipeline for test coverage extraction.
        
        Args:
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
            debug.trace(4, "Skipping bash processing")
            multiline_bash = None
            bash_macros = None
            
        # Process notebook
        if "notebook" not in skip_steps:
            batspp_script = self._convert_notebook_to_batspp(self.notebook_path, use_simple_batspp)
            bats_script = self._convert_batspp_to_bats(batspp_script, multiline_bash, use_simple_batspp)
        else:
            debug.trace(4, "Skipping notebook processing")
            batspp_script = None
            bats_script = None
            
        # Process coverage
        if "coverage" not in skip_steps:
            kcov_output = self._generate_kcov_output(bats_script, multiline_bash)
        else:
            debug.trace(4, "Skipping coverage generation")
            kcov_output = None
            
        # Process cobertura
        if "cobertura" not in skip_steps:
            cobertura_coverage = self._extract_cobertura_coverage(kcov_output)
        else:
            debug.trace(4, "Skipping cobertura extraction")
            cobertura_coverage = None
            
        # Process function coverage
        if "function" not in skip_steps:
            func_coverage = self._generate_function_coverage(cobertura_coverage, bash_macros, json_output=JSON_OUTPUT)
            
            # Always generate alternative function coverage
            if kcov_output:
                alt_coverage = self._generate_alternative_function_coverage(kcov_output, json_output=JSON_OUTPUT)
            else:
                alt_coverage = None
        else:
            debug.trace(4, "Skipping function coverage generation")
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

    def __init__(self, **kwargs):
        """Initialize script with class variables."""
        super().__init__(**kwargs)
        # Initialize attributes that will be set in setup()
        self.bash_source = None
        self.notebook = None
        self.intermediate_output = None
        self.alt_result = None
        self.alt = None
        self.output = None
        self.skip = None
        self.dry_run = None
        self.simple_batspp = None
        self.helper = None

    def setup(self):
        """Extract and initialize command-line arguments."""
        debug.trace(TL.VERBOSE, f"AnalyzeTestCoverageScript.setup(): self={self}")
        
        # Get required arguments
        self.bash_source = self.get_parsed_argument(BASH_SOURCE_ARG)
        self.notebook = self.get_parsed_argument(NOTEBOOK_ARG)
        
        # Validate required arguments
        if not self.bash_source:
            debug.trace(TL.VERBOSE, f"Required argument missing: --{BASH_SOURCE_ARG}")
            sys.exit(1)
        if not system.file_exists(self.bash_source):
            debug.trace(TL.VERBOSE, f"Bash source file not found: {self.bash_source}")
            sys.exit(1)
            
        if not self.notebook:
            debug.trace(TL.VERBOSE, f"Required argument missing: --{NOTEBOOK_ARG}")
            sys.exit(1)
        if not system.file_exists(self.notebook):
            debug.trace(TL.VERBOSE, f"Notebook file not found: {self.notebook}")
            sys.exit(1)
        
        # Get optional arguments with defaults
        self.intermediate_output = self.get_parsed_option(INTERMEDIATE_OUTPUT_ARG)
        self.alt_result = self.get_parsed_option(ALT_RESULT_ARG)
        self.alt = self.get_parsed_option(ALT_ARG)  # Get the new short option
        self.output = self.get_parsed_option(OUTPUT_ARG)
        skip_value = self.get_parsed_option(SKIP_ARG, "")
        self.skip = skip_value.split(",") if skip_value else []
        self.dry_run = self.get_parsed_option(DRY_RUN_ARG)
        self.simple_batspp = self.get_parsed_option(SIMPLE_BATSPP_ARG)
        
        # If intermediate output directory is specified, ensure it exists
        if self.intermediate_output and not system.file_exists(self.intermediate_output):
            gh.full_mkdir(self.intermediate_output)
        
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
        # We don't need to process any input lines for this script
        pass

    def run_main_app(self):
        """Run the main application logic"""
        debug.trace(TL.VERBOSE, "Running main application logic")
        
        # Run the pipeline - always generate alt_function_coverage
        results = self.helper.run_pipeline(
            skip_steps=self.skip,
            use_simple_batspp=self.simple_batspp
        )
        
        # Output results
        if self.output:
            directory = gh.dir_path(self.output)
            if directory and not system.file_exists(directory):
                gh.full_mkdir(directory)

            ## OLD: Before the use of mezcla.file_utils                
            # with open(self.output, 'w', encoding='utf-8') as f:
            #     json.dump(results, f, indent=2)
            fu.write_json(self.output, results)

        else:
            # Check if we should show alternative results (--alt-result or --alt)
            use_alt = self.alt_result or self.alt
            
            # Print the function coverage results to stdout
            if use_alt and results["alt_function_coverage"] and system.file_exists(results["alt_function_coverage"]):
                print(system.read_file(results["alt_function_coverage"]))
            elif results["function_coverage"] and system.file_exists(results["function_coverage"]):
                print(system.read_file(results["function_coverage"]))
            else:
                print(results)

    def run(self):
        """Main execution method"""
        # First, parse arguments and initialize everything
        self.setup()
        
        # Run the main application logic
        self.run_main_app()

## Main
def main():
    """Entry point for the script."""
    app = AnalyzeTestCoverageScript(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=False,
        positional_arguments=[
            (BASH_SOURCE_ARG, "Path to the Bash script to analyze"),
            (NOTEBOOK_ARG, "Path to the Jupyter notebook to analyze")
        ],
        boolean_options=[
            (ALT_RESULT_ARG, "Show alternative function coverage results"),
            (ALT_ARG, "Show alternative function coverage results (shorthand)"),
            (DRY_RUN_ARG, "Print commands without executing them"),
            (SIMPLE_BATSPP_ARG, "Use simple_batspp.py instead of batspp")
        ],
        text_options=[
            (INTERMEDIATE_OUTPUT_ARG, "Directory for intermediate output files"),
            (OUTPUT_ARG, "Path to output JSON results file"),
            (SKIP_ARG, "Comma-separated list of steps to skip (bash,notebook,coverage,cobertura,function)")
        ]
    )
    app.run()

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()