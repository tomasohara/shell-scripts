#! /usr/bin/env python

# batspp_report.py 
# NOTE: BATSPP REQUIRED TO BE INSTALLED
""" SELECTS AN IPYNB TEST FILE,
    CONVERTS THE REPORT TO A BATSPP FILE,
    EXECUTES THE BATSPP FILE,
    REPORTS STORED AT ./tests/reports"""

import os

TEST_PATH = r"./tests/"
REPORT_PATH = f"{TEST_PATH}reports/"
TEST_EXTENSION = (".batspp", ".ipynb")

files_TEST_PATH = os.listdir(TEST_PATH)

for file in files_TEST_PATH:
    
    # CHECKS IF THE FILE ENDS WITH A BATSPP OR IPYNB EXTENSION
    is_batspp = file.endswith(TEST_EXTENSION) 
    
    if is_batspp:
        os.system(f"batspp {file} > {REPORT_PATH}/rpt-{file}.txt")
    


