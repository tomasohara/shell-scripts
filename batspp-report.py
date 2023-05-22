#! /usr/bin/env python

# batspp_report.py 
# NOTE: BATSPP REQUIRED TO BE INSTALLED
""" SELECTS AN IPYNB OR A BATSPP TEST FILE,
    EXECUTES THE FILE,
    REPORTS STORED AT ./tests/reports
    (NOTE: TESTS SHOW THAT BOTH BATSPP AND IPYNB FILES EXECUTE WELL ON BATSPP)"""

import os

TEST_PATH = r"./tests/"
REPORT_PATH = f"{TEST_PATH}reports/"
#REPORT_PATH = f"./tests/reports/"
TEST_EXTENSION = (".batspp", ".ipynb")

files_TEST_PATH = os.listdir(TEST_PATH)

for file in files_TEST_PATH:
    
    # CHECKS IF THE FILE ENDS WITH A BATSPP OR IPYNB EXTENSION
    is_batspp = file.endswith(TEST_EXTENSION) 
    
    if is_batspp:
        os.system(f"batspp {file} --output {REPORT_PATH}/rpt-{file}.txt")
    


