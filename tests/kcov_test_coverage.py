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

## OPTIONS:
## 1. Individual files
## 2. All files

## APPROACHES:
## 1. Find the name of testfiles (from ipynb testfiles or kcov-output/)
## 2. Access the .js file that stores the test scores
## 3. Find the line that contains the details (second last line of .js)
## 4. Access the details (these are in a certain pattern)
## 5. Interpret the data for calculations

## REPORT INFO PATTERN
## 
## ./kcov-output
##  /{testfile-name}
##  /bats.{randomized-hex-16}
##  /bats.{randomized-num-5}.src.{randomized-hex-8}.js
##

JS_PATTERN = f"bats.*/bats.*.src.*.js"
JSON_REGEX = r'\{[^}]*\}'
KCOV_FOLDER = "kcov-output"

instrumented_total = 0
covered_total = 0
ratio_total = []
# coverage_percent = (covered_total/instrumented_total)*100
kcov_folder_exists = gh.file_exists(KCOV_FOLDER)

i = 1
if not kcov_folder_exists:
    print (f"No {KCOV_FOLDER}")
else:
    reports = system.read_directory(f"./{KCOV_FOLDER}/")
    for report in reports:
        ## APPROACH TO EXTRACT TEXT NAME - USE REMOVE EXTENSION AND REMOVE THE REST OF PATTERN FROM THE FILE
        
        REQUIRED_LINE = gh.run(f"cat ./{KCOV_FOLDER}/{report}/{JS_PATTERN} | tail -2 | head -1")
        json_extract = (gh.extract_match_from_text(JSON_REGEX, REQUIRED_LINE)).replace(',}','}')
        report_JSON = json.loads(json_extract)
        
        report_Date = report_JSON["date"]
        report_CMD = report_JSON["command"]
        report_InsLine = report_JSON["instrumented"]
        report_CovLine = report_JSON["covered"]
        report_RatioLine = report_CovLine / report_InsLine

        REPORT_PATTERN = f"""
kcov REPORT [{i}]: {report}
>> Date: {report_Date}
>> Instrumented Lines: {report_InsLine}
>> Covered Lines: {report_CovLine}
>> Coverage Ratio: {round(report_RatioLine, 2)}
"""
                        
        print (REPORT_PATTERN)
        
        ratio_total += [report_RatioLine]
        instrumented_total += report_InsLine
        covered_total += report_CovLine
        
        i += 1

    file_quantity = i - 1

## SUMMARY STATISTICS
RATIO_MEAN = round(np.mean(ratio_total), 4)
RATIO_MEDIAN = round(np.median(ratio_total), 4)
print (f"[SUMMARY STATS]")
print (f"Reports Detected = {file_quantity}")
print (f"Total Instrumented Lines = {instrumented_total}")
print (f"Total Covered Lines = {covered_total}")
print (f"Coverage Ratio [AVG] = {RATIO_MEAN}")
print (f"Coverage Ratio [MEDIAN] = {RATIO_MEDIAN}")
