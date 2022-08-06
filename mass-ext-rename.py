#! /usr/bin/env python
#
# CHANGES EXTENSION OF EVERY FILE WITH A SAME EXTENSION  
# LOCATION: tomasohara/shell-scripts

"""Automates changing extensions for all file (with same extension) at once
    Syntax: (python3) mass-ext-change.py [current_ext] [next_ext] [filepath]"""

# Standard modules
import os
import sys

filename_arg = sys.argv
arg_len = len(filename_arg)

def massExtRename():
    change_count = 0
    extension1 = filename_arg[1]
    extension2 = filename_arg[2]
    EXTENSION_PATH = filename_arg[3] 
    print(f"\nCHANGE OF EXTENSIONS IN {EXTENSION_PATH} : {extension1} ==> {extension2}")
    print("\nCHANGES MADE:\n==========================================================")

    files = os.listdir(EXTENSION_PATH) #<-- FileNotFoundError to be solved / Filepath issues to be fixed

    for file in files:
        ext_true = file.endswith(extension1) #<-- Checks for any file with matching extensions
        if ext_true:
            change_count += 1
            new_file = file.replace(extension1, extension2)
            os.system(f"mv {EXTENSION_PATH}{file} {EXTENSION_PATH}{new_file}")
            print (f"{file} => {new_file}")
    if change_count == 0:
        print (f"NONE: FILES WITH {extension1} EXTENSION DOESN'T EXIST")
            
    print(f"==========================================================\n\nNO. OF CHANGES: {change_count}\n")


if arg_len == 4:
    massExtRename()    
else:
    print("SyntaxError: Invalid number of arguments\nSyntax: (python3) mass-ext-change.py [current_ext] [next_ext] [filepath]")
