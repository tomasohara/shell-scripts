#! /usr/bin/env python

## SCRIPT_NAME: kcov_result.py (Indev Name: kcov_test_coverage.py)

## DESCRIPTION:
# This script is used for generating results and summary statistics of the testfiles reports generated using KCOV (auto_batspp_mezcla.py).
# Doesn't work in the absence of ./kcov-output/ directory.

## REQUIREMENTS:
# 1) mezcla 1.X.X for script usage
# 2) Test reports inside ./kcov-output/ directory (as well as ./kcov-output/ directory) 

## USAGE
# =======
# NOTE: By default, reports of each testfiles and overall summary stats are printed 
# 
# Syntax: ./kcov_result.py <options>
# 
# Options:
#   -h, --help  show this help message and exit
#   --summary   Generates summary only
#   --ro        Generates individual reports of testfiles only
#   --list      Generates lists of testfiles according to the success rate (desc)
#   --export    Generates and stores text reports at ./coverage-reports/

## BUGS & ISSUES
# 1) Issue regarding repetitive outputs in --list option [FIXED]

## TODO
# 1) Add an option --export to export reports in textfile [FIXED]

"""
Calculates and prints the summary (and other info) of test results generated by KCOV.
"""

# Standard modules
import os
import json

# Installed modules
import numpy as np

# Local modules
from mezcla import debug
from mezcla.main import Main
from mezcla import system
from mezcla.my_regex import my_re
from mezcla import glue_helpers as gh

# Constants for argparsing
SUMMARY_MODE = "summary"
INCLUDE_MODE = "include"
EXCLUDE_MODE = "exclude"
LIST_MODE = "list"
REPORT_ONLY_MODE = "ro"
EXPORT_REPORT = "export"

# Function Constants
JS_PATTERN = f"bats.*/bats.*.src.*.js"
JSON_REGEX = r'\{[^}]*\}'
REPORT_EXPORT_PATH = f"./coverage-reports/"
KCOV_FOLDER = "kcov-output"
LIST_MODE_INS = "instrumented_line"
LIST_MODE_RATIO = "ratio"

## Main function: kcov_test_coverage(SUMMARY_OPT, LIST_OPT, REPORT_MODE, INCLUDE_OPT, EXCLUDE_OPT)
kcov_folder_exists = gh.file_exists(KCOV_FOLDER)

class KcovTestCoverage:
    """Consists of functions for the necessary result operations and summary"""
    
    def __init__ (
        self,
        SUMMARY_OPT, 
        LIST_OPT, 
        REPORT_ONLY_OPT, 
        INCLUDE_OPT, 
        EXCLUDE_OPT,
        EXPORT_OPT
    ):
        """Initializer for KcovTestCoverage class"""
        self.SUMMARY_OPT = SUMMARY_OPT
        self.LIST_OPT = LIST_OPT
        self.REPORT_ONLY_OPT = REPORT_ONLY_OPT
        self.INCLUDE_OPT = INCLUDE_OPT
        self.EXCLUDE_OPT = EXCLUDE_OPT
        self.EXPORT_OPT = EXPORT_OPT


    ## TROUBLESOME AREA (argument issues) : AttributeError: 'KcovTestCoverage' object has no attribute 'FILE'
    def do_it(self):
        """Main method for KcovTestCoverage class"""

        ## Workflow
        global facts_array
        facts_array = []
        
        if kcov_folder_exists: 
            self.report_process()
            
            if not self.REPORT_ONLY_OPT:
                
                if self.LIST_OPT:
                    self.list_summary_mode()
                
                if self.SUMMARY_OPT or not self.LIST_OPT:
                    self.summary_stats()

            else:
                print ("\n\t[REPORTS ONLY MODE (--ro) enabled]\t\n")
        else:
            raise Exception(f"Directory Not Found: {KCOV_FOLDER}/ doesn't exist.")

    ## Helper functions for do_it function

    # 0.1. get_test_name_from_testfile
    def get_name_from_testfile(self, FILE):
        """Returns basename from .ipynb testfiles"""
        return gh.basename(FILE, ".ipynb")

    # 0.2. get_index_number
    def get_index_number(self, LIST, ITEM):
        """Returns index number from list of items (counts from 1)"""
        return LIST.index(ITEM) + 1


    # 1. extract_report
    def extract_report(self, report_name, i):
        """Extracts the required line of code from each report by accessing required .js"""

        global report_InsLine, report_CovLine, report_RatioLine, report_JSON, facts_JSON

        REQUIRED_LINE = gh.run(f"cat ./{KCOV_FOLDER}/{report_name}/{JS_PATTERN} | tail -2 | head -1")
        json_extract = (gh.extract_match_from_text(JSON_REGEX, REQUIRED_LINE)).replace(',}','}')
        report_JSON = json.loads(json_extract)
                
        report_Date = report_JSON["date"]
        report_InsLine = report_JSON["instrumented"]
        report_CovLine = report_JSON["covered"]
        report_RatioLine = round(report_CovLine / report_InsLine, 4)

        REPORT_PATTERN = f"""
------------------------------------
kcov REPORT [{i}]: {report_name}
------------------------------------
Date: {report_Date}
Instrumented Lines: {report_InsLine}
Covered Lines: {report_CovLine}
Coverage Ratio: {round(report_RatioLine, 4)}
"""     
        # facts_JSON is used for determining highest and lowest facts
        facts_JSON = {}
        facts_JSON["report_name"] = report_name
        facts_JSON["instrumented_line"] = report_InsLine
        facts_JSON["covered_line"] = report_CovLine
        facts_JSON["ratio"] = report_RatioLine
        facts_array.append(facts_JSON)

        if not (self.SUMMARY_OPT and self.LIST_OPT):
            print (REPORT_PATTERN)
        
        if self.EXPORT_OPT:
            # # TODO: Prettify JSON for export
            # facts_JSON_obj = json.load(facts_JSON)
            # pretty_facts_JSON = json.dumps(facts_JSON_obj)

            # [OLD]: JSON output is replaced by simple output
            # gh.write_file(filename=f"{REPORT_EXPORT_PATH}/{report_name}_REPORT.txt", text=str(facts_JSON))
            export_summary = f"{report_CovLine} out of {report_InsLine} tests passed overall ({report_RatioLine*100}%)"
            gh.write_file(filename=f"{REPORT_EXPORT_PATH}/{report_name}_REPORT.txt", text=export_summary)

    # 2. report_process() uses extract_report(report); act as a calculating function
    def report_process(self):
        """Extracts information from extract_report(report_name); calculates total lines and ratios"""

        i = 1
        global ratio_array, instrumented_array, covered_array, REPORT_LIST
        ratio_array = []
        instrumented_array = []
        covered_array = []
        global file_quantity

        reports = system.read_directory(f"./{KCOV_FOLDER}/")
        
        # REWORK TBD: Inclusion of multiple testfiles in OPTIONS --include / --exclude
        if self.EXCLUDE_OPT:
            reports.remove(self.get_name_from_testfile(self.EXCLUDE_OPT))
            # print (reports)
        elif self.INCLUDE_OPT:
            reports = [self.get_name_from_testfile(self.INCLUDE_OPT)]
        # END OF Rework

        for report in reports:
            self.extract_report(report, i)
            ratio_array += [report_RatioLine]
            instrumented_array += [report_InsLine]
            covered_array += [report_CovLine]
            i += 1

        file_quantity = i - 1

        REPORT_LIST = reports

    # 3. summary_stats() prints the required summary stats and facts of the report
    def summary_stats(self):
        """Prints out the overall summary stats of file calculations"""

        RATIO_MEAN = round(np.mean(ratio_array), 4)
        RATIO_MEDIAN = round(np.median(ratio_array), 4)

        INSTRUMENTED_TOTAL = np.sum(instrumented_array)
        COVERED_TOTAL = np.sum(covered_array)

        INSTRUMENTED_MAX = np.max(instrumented_array)
        INSTRUMENTED_MIN = np.min(instrumented_array)

        HIGHEST_RATIO = np.max(ratio_array)
        LOWEST_RATIO = round (np.min(ratio_array), 4)

        for fact in facts_array:
            if fact["instrumented_line"] == INSTRUMENTED_MAX:
                LARGEST_TESTFILE = fact["report_name"]
            if fact["instrumented_line"] == INSTRUMENTED_MIN:
                SMALLEST_TESTFILE = fact["report_name"]
            if fact["ratio"] == HIGHEST_RATIO and fact["report_name"] != "hello-world-basic" "hello-world-revised":
                HIGHEST_SUCCESS_TESTFILE = fact["report_name"]
            if fact["ratio"] == LOWEST_RATIO:
                LOWEST_SUCCESS_TESTFILE = fact["report_name"]    
        
        if self.SUMMARY_OPT: print ("\n[SUMMARY MODE (--summary) ENABLED]")

        print (f"\n===============================================\n")
        print (f"SUMMARY STATISTICS: ")
        
        ## REWORK TBD: For multiple arguments (--include/--exclude mode)
        print (f"------------------------------------\n")
        print (f"EXCLUDED TESTS: {self.get_name_from_testfile(self.EXCLUDE_OPT) if self.EXCLUDE_OPT else None}")
        print (f"EXCLUSIVELY INCLUDED TESTS: {self.get_name_from_testfile(self.INCLUDE_OPT) if self.INCLUDE_OPT else None}")

        print (f"\nREPORTS DETECTED: [{file_quantity}]")
        print (f"Total Instrumented Lines = {INSTRUMENTED_TOTAL}")
        print (f"Total Covered Lines = {COVERED_TOTAL}")
        print (f"Coverage Ratio: ")
        print (f"   1. AVERAGE = {RATIO_MEAN}")
        print (f"   2. MEDIAN = {RATIO_MEDIAN}")
        print (f"   3. TOTAL LINES (COV/INS) = {round(COVERED_TOTAL/INSTRUMENTED_TOTAL, 4)}")
        print (f"\nFILES FACTS:")
        print (f"------------------------------------\n")
        print (f"Largest Testfile:\n>> {LARGEST_TESTFILE} [LINES = {INSTRUMENTED_MAX}]")
        print (f"\nSmallest Testfile:\n>> {SMALLEST_TESTFILE} [LINES = {INSTRUMENTED_MIN}]")
        print (f"\nHighest Success Rate:\n>> {HIGHEST_SUCCESS_TESTFILE} [RATIO = {HIGHEST_RATIO}]")
        print (f"\nLowest Success Rate:\n>> {LOWEST_SUCCESS_TESTFILE} [RATIO = {LOWEST_RATIO}]")
        print (f"\n===============================================\n")

    # 4. list_summary_mode is enabled for --list option (returns a list of testfiles)    
    def list_summary_mode(self):
        "Prints out testfiles in a list on the basis of instrumented lines and ratio"

        def report_name_by_value(fact_list, v, mode):
            "List generation in descending order for a certain mode"
            for fact in fact_list:
                if fact[mode] == v:
                    report_title = fact['report_name']
                    fact_list.pop(fact_list.index(fact))
                    return f"{report_title}\n\t\t\t\t\t\t[{fact[mode]}]"
                    
        print (f"\n====================================")
        print ("    LIST MODE (--list) ENABLED")
        
        SUMMARY_INS = []
        SUMMARY_RATIO = []
        
        for fact in facts_array:
            SUMMARY_INS += [fact["instrumented_line"]]
            SUMMARY_RATIO += [fact["ratio"]]
        
        SUMMARY_INS.sort(reverse = True)
        SUMMARY_RATIO.sort(reverse = True)
        
        # ISSUE (OR NOT): Tests with equal values show same rank
        print (f"\n------------------------------------")
        print (f"LARGEST TESTFILES (DESC): ")
        print (f"------------------------------------")
        fa1 = facts_array.copy()
        
        for value_INS in SUMMARY_INS:
            print (f"{self.get_index_number(SUMMARY_INS, value_INS)}) {report_name_by_value(fa1, value_INS, LIST_MODE_INS)}")
        
        print (f"\n------------------------------------")
        print ("MOST SUCCESSFUL TESTFILES (DESC): ")
        print (f"------------------------------------")
        fa2 = facts_array.copy()
        
        for value_RATIO in SUMMARY_RATIO:
            print (f"{self.get_index_number(SUMMARY_RATIO, value_RATIO)}) {report_name_by_value(fa2, value_RATIO, LIST_MODE_RATIO)}")
       
        print (f"\n=====================================\n")
    
## END OF MAIN
# ===============================================================================================================

class Script(Main):
    """Adhoc script class (e.g., no I/O loop): just parses args"""
    summary_mode = False
    list_mode = False
    report_only_mode = False
    include_mode = ""
    exclude_mode = ""
    export_report = False

    def get_entered_text(
        self,
        label:str,
        default:str='',
        ) -> str:
        """
        Return entered LABEL var/arg text by command-line or enviroment variable,
        also can be specified a DEFAULT value
        """
        result = (self.get_parsed_argument(label=label.lower()) or
                    system.getenv_text(var=label.upper()))
        result = result if result else default
        debug.trace(7, f'batspp.get_entered_text(label={label}) => {result}')
        return result

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)

        # For options
        self.summary_mode = self.get_parsed_option(SUMMARY_MODE, self.summary_mode)
        self.list_mode = self.get_parsed_option(LIST_MODE, self.list_mode)
        self.report_only_mode = self.get_parsed_option(REPORT_ONLY_MODE, self.report_only_mode)
        self.include_mode = self.get_entered_text(INCLUDE_MODE, self.include_mode)
        self.exclude_mode = self.get_entered_text(EXCLUDE_MODE, self.exclude_mode)
        self.export_report = self.get_parsed_option(EXPORT_REPORT, self.export_report)
        
        debug.trace_object(5, self, label="Script instance")

    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)
        # # OLD (For class-less approach):
        # kcov_test_coverage(
        #     self.summary_mode, 
        #     self.list_mode, 
        #     self.report_only_mode, 
        #     self.include_mode,
        #     self.exclude_mode
        # )
        kcov_test_coverage = KcovTestCoverage(
            self.summary_mode, 
            self.list_mode, 
            self.report_only_mode, 
            self.include_mode,
            self.exclude_mode,
            self.export_report
        )
        kcov_test_coverage.do_it()

#-------------------------------------------------------------------------------
    
if __name__ == "__main__":
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    debug.trace_fmt(4, "Environment options: {eo}",
                    eo=system.formatted_environment_option_descriptions())
    
    app = Script(
        description=__doc__,
        skip_input= True,
        manual_input=True,
        auto_help=False,
        multiple_files=False,

        boolean_options=[
            (SUMMARY_MODE, f"Generates summary only"),
            (REPORT_ONLY_MODE, f"Generates individual reports of testfiles only"),
            (LIST_MODE, f"Generates lists of testfiles according to the success rate (desc)"),
            (EXPORT_REPORT, f"Generates and stores text reports at ./coverage-reports/")
        ],
        
        text_options=[
            (INCLUDE_MODE, f"Only includes the tests mentioned in the command"),
            (EXCLUDE_MODE, f"Excludes any tests mentioned in the command")
        ]
    )
    
    app.run()
