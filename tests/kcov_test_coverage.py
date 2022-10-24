#! /usr/bin/env python

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

# Constants

JS_PATTERN = f"bats.*/bats.*.src.*.js"
JSON_REGEX = r'\{[^}]*\}'
KCOV_FOLDER = "kcov-output"

kcov_folder_exists = gh.file_exists(KCOV_FOLDER)

def kcov_test_coverage():

    # 1. extract_report()
    def extract_report(report_name, i):
        """Extracts the required line of code from each report by accessing required .js"""

        global report_InsLine, report_CovLine, report_RatioLine

        REQUIRED_LINE = gh.run(f"cat ./{KCOV_FOLDER}/{report_name}/{JS_PATTERN} | tail -2 | head -1")
        json_extract = (gh.extract_match_from_text(JSON_REGEX, REQUIRED_LINE)).replace(',}','}')
        report_JSON = json.loads(json_extract)
                
        report_Date = report_JSON["date"]
        # report_CMD = report_JSON["command"]
        report_InsLine = report_JSON["instrumented"]
        report_CovLine = report_JSON["covered"]
        report_RatioLine = (report_CovLine / report_InsLine)

        REPORT_PATTERN = f"""
kcov REPORT [{i}]: {report_name}
>> Date: {report_Date}
>> Instrumented Lines: {report_InsLine}
>> Covered Lines: {report_CovLine}
>> Coverage Ratio: {round(report_RatioLine, 4)}
"""           
        print (REPORT_PATTERN)

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
            i += 1
            ratio_array += [report_RatioLine]
            instrumented_array += [report_InsLine]
            covered_array += [report_CovLine]

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

        print (f"SUMMARY STATISTICS: ")
        print (f"====================================")
        print (f"Reports Detected = {file_quantity}")
        print (f"Total Instrumented Lines = {INSTRUMENTED_TOTAL}")
        print (f"Total Covered Lines = {COVERED_TOTAL}")
        print (f"Coverage Ratio [AVERAGE] = {RATIO_MEAN}")
        print (f"Coverage Ratio [MEDIAN] = {RATIO_MEDIAN}")
        print (f"")
        print (f"Largest Testile: \n>> {None} [LINES: {INSTRUMENTED_MAX}]")
        print (f"Smallest Testfile: \n>> {None} [LINES: {INSTRUMENTED_MIN}]")
        print (f"Highest Success Rate:\n>> {None} [RATIO: {HIGHEST_RATIO}]")
        print (f"Lowest Success Rate:\n>> {None} [RATIO: {LOWEST_RATIO}]")
        print (f"====================================")

    ## main function
    if kcov_folder_exists:
        report_process()   
    else:
        print (f"Error: {KCOV_FOLDER} doesn't exist.")
    summary_stats()

## END OF MAIN
# =============================================================================================================== #

class Script(Main):
    """Adhoc script class (e.g., no I/O loop): just parses args"""
    # no_report = False
    # kcov_report = False
    # text_report = False

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        # self.no_report = self.get_parsed_option(NO_REPORT, self.no_report)
        # self.kcov_report = self.get_parsed_option(KCOV_REPORT, self.kcov_report)
        # self.text_report = self.get_parsed_option(TEXT_REPORT, self.text_report)
        debug.trace_object(5, self, label="Script instance")

    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)
        kcov_test_coverage()

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
        # boolean_options=[(NO_REPORT, "No reports are generated, testfiles are shown"),
        #                  (TEXT_REPORT, f"Textfile based reports generated, stored at ./{TXT_STORE}"),
        #                  (KCOV_REPORT, f"KCOV (HTML based) reports generated, stored at ./{KCOV_STORE}/")]
        )
    
    app.run()





