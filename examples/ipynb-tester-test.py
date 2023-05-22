#! /usr/bin/env python
#
# Automates test for batspp.py by converting .ipynb to .batspp  
# LOCATION: tomasohara/shell-scripts

"""Automates test for batspp.py by converting .ipynb to .batspp"""

# Standard modules
import os
import subprocess as sp


# STEP 1 - Converting Jupyter files to batspp test files
BATSPP_RESULT = "batspp_result.bats"
TEST_DIR= r"./tests"
files = os.listdir(test_dir)

for file_name in files:
    old_name = os.path.join(test_dir, file_name)
    new_name = old_name.replace(".ipynb", ".batspp")
    #new_name = old_name.replace(".batspp", ".ipynb")
    os.rename(old_name, new_name)

    is_batspp = file_name.endswith(".batspp")

    # IF EXTENSTION HAS .batspp THEN batspp IS EXECUTED
    if is_batspp:
        os.system(f"batspp --source ./{file_name} --output ./batspp-output/{BATSPP_RESULT}")



# STEP 2 - EXECUTE EACH FILE HAVING THE EXTENSION .batspp

# os.system("command to be executed")

