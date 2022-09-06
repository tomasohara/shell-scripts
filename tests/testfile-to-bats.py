#! /usr/bin/env python

import sys
import os

filename_arg = sys.argv
file_in_ipynb = filename_arg[1]

def batspp_rename():
    file_in_batspp = file_in_ipynb.replace(".ipynb", ".bats")#<--CONVERTS EXTENSION TO BATSPP
    RENAME_COMMAND = f"mv {file_in_ipynb} {file_in_batspp}"#<--COMMAND TO BE EXECUTED
    
    os.system(RENAME_COMMAND)
    print(f"Changes were made to {file_in_ipynb}.\n\nFILE RENAMED:\n{file_in_ipynb} --> {file_in_batspp}")

# START OF MAIN #
if ".ipynb" in file_in_ipynb:
    batspp_rename()
else:
    print (f"The selected file is not an IPython file.\nNo changes were made to the file: {file_in_ipynb}")    
# END OF MAIN #
