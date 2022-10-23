#! /usr/bin/env python
# 
# SCRIPT NAME: auto_batspp.py (Indev Name: tom_auto_batspp_mezcla.py)
# 
# DESCRIPTION
# =============
# This script is designed to identify test-files (.ipynb files from shell-scripts/tests directory),
# automate the execution of test-files and generate reports (either text based or HTML based) as per
# requirements of the user. Also shows any faulty/error-prone testfiles in ./tests directory. 
#
# The given directories are created when the script is executed:
# 1. bats-only/ stores bats-file (.bats) after testfile exection
# 2. batspp-only/ stores batspp-file after conversion of testfiles (from .ipynb to .batspp)
# 3. txt-reports/ stores textfile (.txt) reports after testfile execution
# 4. kcov-reports/ stores HTML based reports after a testfile is executed (PATH: ./kcov-reports/{testfile-name}/index.html)
#
# auto_batspp.py requires the following libraries/scripts:
# 1. Batspp 1.5.X (simple_batspp.py) for process execution
# 2. jupyter_to_batspp.py for converting .ipynb files to batspp compatible (.batspp) files
# 3. mezcla 1.X.X for script usage
# 4. kcov for HTML based report generation
#
# USAGE
# =======
# NOTE: By default, only .bats files are generated and stored at ./tests/bats-only/
# 
# Syntax: ./auto_batspp.py <options>
# 
# Options:
#   --help, -h          show help message and exit
#   --no-reports        No reports are generated, testfiles are shown
#   --text              Textfile based reports generated, stored at ./txt-reports
#   --kcov              KCOV (HTML based) reports generated, stored at ./kcov-output/
# 
# BUGS AND ISSUES
# =================
# BUG [0]: All testfiles labelled "faulty" at very first run, works well after second run
#

"""
    Test Automation & Report Generation for .ipynb testfiles (uses batspp 1.5.X)
    Batspp files generated by default (stored at ./batspp-only)
"""

# Standard modules
import os

# Installed modules
import numpy

# Local modules
from mezcla import debug
from mezcla.main import Main
from mezcla import system
from mezcla.my_regex import my_re
from mezcla import glue_helpers as gh

# Constants for switches omitting leading dashes (e.g., DEBUG_MODE = "debug-mode")
NO_REPORT = "no-reports"
KCOV_REPORT = "kcov"
TEXT_REPORT = "text"

# Other constants
IPYNB = ".ipynb"
BATSPP = ".batspp"
BATS = ".bats"
TXT = ".txt"
    
BATSPP_STORE = "batspp-only"
BATS_STORE = "bats-only"
TXT_STORE = "txt-reports"
KCOV_STORE = "kcov-output"

ESSENTIAL_DIRS = [BATSPP_STORE, BATS_STORE, KCOV_STORE, TXT_STORE]
    
ESSENTIAL_DIRS_present = all(gh.file_exists(dir) for dir in ESSENTIAL_DIRS)
files = system.read_directory("./")

## TODO:
## # Environment options
## # Note: These are just intended for internal options, not for end users.
## # It also allows for enabling options in one place rather than four
## # (e.g., [Main member] initialization, run-time value, and argument spec., along
## # with string constant definition).
## #
## FUBAR = system.getenv_bool("FUBAR", False,
##                             description="Fouled Up Beyond All Recognition processing")

# DEBUG_LEVEL WORKS FROM 4 TO 5 TO ...


#--------------------------------------------------------------------------------

def auto_batspp(NO_OPTION, KCOV_OPTION, TXT_OPTION):
    """Main function for running batspp, 
    Note: uses following options from argpase derived via Script class below:
       NO_OPTION (no reports), TXT_OPTION (text reports), and KCOV_OPTION (KCOV HTML reports)"""

    # 0.1) CHECKING IF THE DIRECTORY EXISTS
    def essential_dir_exists():
        if not ESSENTIAL_DIRS_present:
            gh.create_directory(BATS_STORE)
            gh.create_directory(BATSPP_STORE)
            gh.create_directory(TXT_STORE)
            gh.create_directory(KCOV_STORE)
    
    # 1) Identifying .ipynb files
    def ipynb_identify():
        global ipynb_array
        ipynb_array = []
        i = 1
        print("\n=== BATSPP REPORT GENERATOR (simple_batspp.py / BATSPP 1.5.X) ===\n")
        for file in files:
            if file.endswith(IPYNB):
                print(f"JUPYTER TESTFILE FOUND [{i}]: {file}")
                ipynb_array += [file]
                i += 1
        print(f"\nTOTAL JUPYTER FILE FOUND: {i-1}")

    # 2) Generating .batspp files from .ipynb files

    def batspp_generation():
        global ipynb_count
        ipynb_count = 0
        i = 1
        print(f"\n=== GENERATING BATSPP FILES ===\n")
        for file in files:
            if file.endswith(IPYNB):
                batspp_from_ipynb = file.replace(IPYNB, BATSPP)
                print (f"IPYNB TESTFILE [{i}]: {file} => {batspp_from_ipynb}")

                gh.run(f"./jupyter_to_batspp.py ./{file} --output ./{BATSPP_STORE}/{batspp_from_ipynb}")
                i += 1
        ipynb_count = i - 1

    # 3) Executing batspp files & storing them as bats
    def output_generation():
        
        global batspp_count
        batspp_count = 0

        def not_no_option():

            def text_report_func(FILE, BATSPP_2_TXT):
                TXT_MESSAGE = f"TEXT REPORT PATH: ./{TXT_STORE}/{BATSPP_2_TXT}"
                gh.run(f"./simple_batspp.py ./{BATSPP_STORE}/{FILE} --output ./{TXT_STORE}/{BATSPP_2_TXT}")
                print (gh.indent(TXT_MESSAGE, indentation="  >>  ", max_width=512))
                
            def bats_report_func(FILE, BATSPP_2_BATS):
                BATS_MESSAGE = f"BATSFILE PATH: ./{BATS_STORE}/{BATSPP_2_BATS}"
                print (gh.indent(BATS_MESSAGE, indentation="  >>  ", max_width=512))
                gh.run(f"./simple_batspp.py ./{BATSPP_STORE}/{FILE} --output ./{BATS_STORE}/{BATSPP_2_BATS}")

            def kcov_report_func():
                KCOV_MESSAGE = f"KCOV REPORT PATH: ./{KCOV_STORE}/{kcov_folder}/"
                print(gh.indent(KCOV_MESSAGE, indentation="  >>  ", max_width=512))
                gh.run(f"kcov ./{KCOV_STORE}/{kcov_folder} bats ./{BATS_STORE}/{batspp_to_bats}")

            global batspp_count
            batspp_count = 0
            i = 1
            for file in filesys_bpp:

                if file.endswith(BATSPP):
                    batspp_to_bats = file.replace(BATSPP, BATS)
                    batspp_to_txt = file.replace(BATSPP, TXT)
                    kcov_folder = gh.remove_extension(file, BATSPP)
                    
                    print(f"\nBATSPP FILE DETECTED [{i}]: {file}\n")
                    
                    if TXT_OPTION:
                        text_report_func(file, batspp_to_txt)
                    else:
                        bats_report_func(file, batspp_to_bats)

                        if KCOV_OPTION:
                            kcov_report_func()
                    i += 1
                        
            
            batspp_count = i - 1
        
        print ("\n\n========== BATS GENERATED ==========\n")   
        if not NO_OPTION:
            not_no_option()
        else:
            NO_REPORT_MESSAGE = f"Skipping batspp check (no-reports option provided)"
            print(gh.indent(NO_REPORT_MESSAGE, indentation="  >>  ", max_width=512))
    
    # 4) Mentioning any errors in ipynb testfiles
    def working_tests():
        global working_testfiles
        working_testfiles = []
        
        for file in filesys_bpp:

            if file.endswith(BATSPP):
                BI_check = [file.replace(".batspp", ".ipynb")]
                working_testfiles += BI_check

    # 5) Summary Statistics
    def summary_stats():
        set_wt = set(working_testfiles)
        error_testfiles = [tf for tf in ipynb_array if tf not in set_wt]
        faulty_count = ipynb_count - batspp_count
        
        print(f"\n======================================================")
        print(f"SUMMARY STATISTICS:\n")
        print(f"IPYNB FILES PRESENT: {ipynb_count}")
        print(f"BATSPP FILES GENERATED: {batspp_count if TXT_OPTION or NO_OPTION != True else 'N/A'}")
        print(f"NO. OF FAULTY TESTFILES: {faulty_count if TXT_OPTION or NO_OPTION != True else 'N/A'}")
        print(f"\nFAULTY TESTFILES:")
        if faulty_count == 0:
            print ("None")
        else: 
            for tf in error_testfiles:  
                print(f">> {tf}")
        print(f"======================================================")

    # [END OF FUNCTION] FUNCTION CALL - LINING UP ALL NECESSARY FUNCTIONS
    essential_dir_exists()
    filesys_bpp = system.read_directory("./batspp-only/")
    ipynb_identify()
    batspp_generation()
    output_generation()
    working_tests()
    summary_stats()

#................................................................................

class Script(Main):
    """Adhoc script class (e.g., no I/O loop): just parses args.
    Note: invokes auto_batspp above to do real processing"""
    no_report = False
    kcov_report = False
    text_report = False

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        self.no_report = self.get_parsed_option(NO_REPORT, self.no_report)
        self.kcov_report = self.get_parsed_option(KCOV_REPORT, self.kcov_report)
        self.text_report = self.get_parsed_option(TEXT_REPORT, self.text_report)
        debug.trace_object(5, self, label="Script instance")

    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)
        auto_batspp(self.no_report, self.kcov_report, self.text_report)

#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    debug.trace_fmt(4, "Environment options: {eo}",
                    eo=system.formatted_environment_option_descriptions())
    app = Script(
        description=__doc__,
        # Note: skip_input controls the line-by-line processing, which is inefficient but simple to
        # understand; in contrast, manual_input controls iterator-based input (the opposite of both).
        skip_input=True,
        manual_input=True,
        auto_help=False,
        boolean_options=[(NO_REPORT, "No reports are generated, testfiles are shown"),
                         (TEXT_REPORT, f"Textfile based reports generated, stored at ./{TXT_STORE}"),
                         (KCOV_REPORT, f"KCOV (HTML based) reports generated, stored at ./{KCOV_STORE}/")])
    app.run()

