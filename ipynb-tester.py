#! /usr/bin/env python
#
# Automates test for batspp.py by converting .ipynb to .batspp  
# LOCATION: tomasohara/shell-scripts

"""Automates test for batspp.py by converting .ipynb to .batspp"""

# Standard modules
import os
import glob
import subprocess as sp

# STEP 1 - Converting Jupyter files to batspp test files
TEST_DIR= r"./tests"
IPYNB_EXCLUSIVE_AREA  = "ipynb-area"
BATSPP_RESULT = "batspp_result.bats"
IPYNB_EXT_PATH = f"{TEST_DIR}/*.ipynb"

files = os.listdir(TEST_DIR)
ipynb_files = glob.glob(IPYNB_EXT_PATH)

for file in files:
    file_names = os.path.join(TEST_DIR, file)
    
    # SELECTING ipynb FILES FROM ALL ITEMS
    for ipynb_file in ipynb_files:
        ipynb_file = str(ipynb_file)
        
        if ipynb_file in file_names:
            os.makedirs(f"{TEST_DIR}/{IPYNB_EXCLUSIVE_AREA}")
    print(file_names)


