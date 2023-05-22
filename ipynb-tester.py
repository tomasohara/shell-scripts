#! /usr/bin/env python
#
# Automates test for batspp.py by converting .ipynb to .batspp  
# LOCATION: tomasohara/shell-scripts

"""Automates test for batspp.py by converting .ipynb to .batspp"""

# Standard modules
import os

# STEP 1 - Converting Jupyter files to batspp test files
TEST_DIR= r"./tests"
IPYNB_EXCLUSIVE_AREA  = "ipynb-area"
BATSPP_REPORT_DIR = f"{TEST_DIR}/{IPYNB_EXCLUSIVE_AREA}"
EXE_REPORT_DIR = f"{TEST_DIR}/reports"

files = os.listdir(TEST_DIR)

for file in files:
        file_name_ipynb = str(file)
        file_name_batspp = file_name_ipynb.replace(".ipynb", ".batspp")
        if ".ipynb" in file_name_ipynb:
            
            os.system(f"mv {TEST_DIR}/{file_name_ipynb} {TEST_DIR}/{file_name_batspp}")
            os.system(f"batspp {TEST_DIR}/{file_name_batspp} --output {BATSPP_REPORT_DIR}/bpp_report-{file_name_batspp}.txt > {EXE_REPORT_DIR}/exe_report-{file_name_batspp}.txt")
            os.system(f"mv {TEST_DIR}/{file_name_batspp} {TEST_DIR}/{file_name_ipynb}")

## OLD CODE
# #! /usr/bin/env python
# #
# # Automates test for batspp.py by converting .ipynb to .batspp  
# # LOCATION: tomasohara/shell-scripts

# """Automates test for batspp.py by converting .ipynb to .batspp"""

# # Standard modules
# import os
# import glob

# # STEP 1 - Converting Jupyter files to batspp test files
# TEST_DIR= r"./tests"
# IPYNB_EXCLUSIVE_AREA  = "ipynb-area"
# BATSPP_REPORT_DIR = f"{TEST_DIR}/{IPYNB_EXCLUSIVE_AREA}"
# EXE_REPORT_DIR = f"{TEST_DIR}/reports"
# IPYNB_EXT_PATH = f"{TEST_DIR}/*.ipynb"

# files = os.listdir(TEST_DIR)
# ipynb_files = glob.glob(IPYNB_EXT_PATH)

# for file in files:
#     file_names = os.path.join(TEST_DIR, file)
#     # SELECTING ipynb FILES FROM ALL ITEMS
#     for ipynb_file in ipynb_files:
        
#         ipynb_file = str(ipynb_file)
#         renamed_ipy2bats_file = str(ipynb_file).replace(".ipynb", ".batspp")

#         if ipynb_file in file_names:
#             #< STEP 1: RENAMING IPYNB FILE TO BATSPP FILE >#
#             os.system(f"mv {ipynb_file} {renamed_ipy2bats_file}")
            
#             #< STEP 2: PERFORM BATSPP OPERATON ON BATSPP FILE AND REPORTS ARE GENERATED >#
#             os.system(f"batspp {renamed_ipy2bats_file} --output {BATSPP_REPORT_DIR}/bpp_report_{renamed_ipy2bats_file}.txt > {EXE_REPORT_DIR}/exe_report_{renamed_ipy2bats_file}")

#             #< STEP 3: CONVERT BATSPP FILE BACK TO IPYNB >#
#             os.system(f"mv {renamed_ipy2bats_file} {ipynb_file}")

    

