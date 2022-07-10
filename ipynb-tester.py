#! /usr/bin/env python
#
# Automates test for batspp.py by converting .ipynb to .batspp  

"""Automates test for batspp.py by converting .ipynb to .batspp"""

# Standard modules
import re
import os

# Converting Jupyter files to batspp test files
test_dir = r"./tests"
files = os.listdir(test_dir)

for file_name in files:
    old_name = os.path.join(test_dir, file_name)
    new_name = old_name.replace(".ipynb", ".batspp")
    #new_name = old_name.replace(".batspp", ".ipynb")
    os.rename(old_name, new_name)
    
