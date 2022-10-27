#! /usr/bin/env python

## DESCRIPTION:

"""
Calculates and prints the success rate of tests (and other info) using kcov reports
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
INCLUDE_MODE = "in"
EXCLUDE_MODE = "ex"
LIST_MODE = "list"

# Function Constants
JS_PATTERN = f"bats.*/bats.*.src.*.js"
JSON_REGEX = r'\{[^}]*\}'
KCOV_FOLDER = "kcov-output"

## Main function: kcov_test_coverage(SUMMARY_OPT, LIST_OPT, INCLUDE_OPT, EXCLUDE_OPT)
kcov_folder_exists = gh.file_exists(KCOV_FOLDER)

def kcov_test_coverage(SUMMARY_OPT, LIST_OPT):
    
    global facts_array
    facts_array = []

    # 1. extract_report()
    def extract_report(report_name, i):
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
kcov REPORT [{i}]: {report_name}
>> Date: {report_Date}
>> Instrumented Lines: {report_InsLine}
>> Covered Lines: {report_CovLine}
>> Coverage Ratio: {round(report_RatioLine, 4)}
"""     
        # facts_JSON is used for determining highest and lowest facts
        facts_JSON = {}
        facts_JSON["report_name"] = report_name
        facts_JSON["instrumented_line"] = report_InsLine
        facts_JSON["covered_line"] = report_CovLine
        facts_JSON["ratio"] = report_RatioLine
        facts_array.append(facts_JSON)

        if not SUMMARY_OPT:
            print (REPORT_PATTERN)

            
        # print (REPORT_PATTERN)


    # 2. report_process() uses extract_report(report); act as a calculating function
    def report_process():
        """Extracts information from extract_report(report_name); calculates total lines and ratios"""

        i = 1
        global ratio_array, instrumented_array, covered_array
        ratio_array = []
        instrumented_array = []
        covered_array = []
        global file_quantity

        reports = system.read_directory(f"./{KCOV_FOLDER}/")
        
        for report in reports:
            extract_report(report, i)
            ratio_array += [report_RatioLine]
            instrumented_array += [report_InsLine]
            covered_array += [report_CovLine]
            i += 1

        file_quantity = i - 1
        
    def summary_stats():
        """Prints out the overall summary stats of file calculations"""

        RATIO_MEAN = round(np.mean(ratio_array), 4)
        RATIO_MEDIAN = round(np.median(ratio_array), 4)

        INSTRUMENTED_TOTAL = np.sum(instrumented_array)
        COVERED_TOTAL = np.sum(covered_array)
        
        INSTRUMENTED_MAX = np.max(instrumented_array)
        INSTRUMENTED_MIN = np.min(instrumented_array)

        HIGHEST_RATIO = np.max(ratio_array)
        LOWEST_RATIO = round (np.min(ratio_array), 4)

        ## TODO: Work for list-mode (list all the files in descending order [success rate])
        for fact in facts_array:
            if fact["instrumented_line"] == INSTRUMENTED_MAX:
                LARGEST_TESTFILE = fact["report_name"]
            if fact["instrumented_line"] == INSTRUMENTED_MIN:
                SMALLEST_TESTFILE = fact["report_name"]
            if fact["ratio"] == HIGHEST_RATIO and fact["report_name"] != "hello-world-basic" "hello-world-revised":
                HIGHEST_SUCCESS_TESTFILE = fact["report_name"]
            if fact["ratio"] == LOWEST_RATIO:
                LOWEST_SUCCESS_TESTFILE = fact["report_name"]    
        
        if SUMMARY_OPT: print ("\n[SUMMARY MODE (--summary) ENABLED]")
        print (f"\n====================================")
        print (f"SUMMARY STATISTICS: ")
        print (f"------------------------------------")
        print (f"REPORTS DETECTED: [{file_quantity}]")
        print (f"Total Instrumented Lines = {INSTRUMENTED_TOTAL}")
        print (f"Total Covered Lines = {COVERED_TOTAL}")
        print (f"Coverage Ratio: ")
        print (f"   1. AVERAGE = {RATIO_MEAN}")
        print (f"   2. MEDIAN = {RATIO_MEDIAN}")
        print (f"   3. TOTAL LINES (COV/INS) = {round(COVERED_TOTAL/INSTRUMENTED_TOTAL, 4)}")
        print (f"\nFILES FACTS:")
        print (f"------------------------------------")
        print (f"Largest Testile:\n>> {LARGEST_TESTFILE} [LINES = {INSTRUMENTED_MAX}]")
        print (f"\nSmallest Testfile:\n>> {SMALLEST_TESTFILE} [LINES = {INSTRUMENTED_MIN}]")
        print (f"\nHighest Success Rate:\n>> {HIGHEST_SUCCESS_TESTFILE} [RATIO = {HIGHEST_RATIO}]")
        print (f"\nLowest Success Rate:\n>> {LOWEST_SUCCESS_TESTFILE} [RATIO = {LOWEST_RATIO}]")
        print (f"====================================")
        
        def list_summary_mode():
            SUMMARY_INS = []
            SUMMARY_COV = []
            SUMMARY_RATIO = []
            
            for fact in facts_array:
                SUMMARY_INS += [fact["instrumented_line"]]
                SUMMARY_COV += [fact["covered_line"]]
                SUMMARY_RATIO += [fact["ratio"]]
            
            SUMMARY_INS.sort(reverse=True)
            SUMMARY_COV.sort(reverse=True)
            SUMMARY_RATIO.sort(reverse=True)

            ## TO BE CONTINUED - FOR LIST_MODE
            # for fact in facts_array:
            #     for value in SUMMARY_INS:
            #         print ()
 
        list_summary_mode()
                
            
    ## main function - Work it later on
    if kcov_folder_exists:
        report_process()
        summary_stats()
    else:
        raise Exception(f"Directory Not Found: {KCOV_FOLDER}/ doesn't exist.")
    
    

## END OF MAIN
# =============================================================================================================== #

class Script(Main):
    """Adhoc script class (e.g., no I/O loop): just parses args"""
    summary_mode = False
    # include_mode = False
    # exclude_mode = False
    list_mode = False

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        self.summary_mode = self.get_parsed_option(SUMMARY_MODE, self.summary_mode)
        self.list_mode = self.get_parsed_option(LIST_MODE, self.list_mode)
        # self.include_mode = self.get_parsed_argument(INCLUDE_MODE, self.include_mode)
        # self.exclude_mode = self.get_parsed_option(TEXT_REPORT, self.exclude_mode)
        debug.trace_object(5, self, label="Script instance")

    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)
        kcov_test_coverage(self.summary_mode, self.list_mode)

#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    debug.trace_fmt(4, "Environment options: {eo}",
                    eo=system.formatted_environment_option_descriptions())
    app = Script(
        description=__doc__,
        skip_input=True,
        manual_input=True,
        auto_help=False,
        boolean_options=[(SUMMARY_MODE, f"Generates summary only"),
        #                  (INCLUDE_MODE, f"Only include the tests mentioned in the command")],
        #                  (EXCLUDE_MODE, f"Excludes any tests mentioned in the command")]
                          (LIST_MODE, f"Lists all the testfiles according to the success rate (desc)")]
        )
    
    app.run()





