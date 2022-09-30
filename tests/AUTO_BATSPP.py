#! /usr/bin/env python

#| NOTE: USES batspp 1.X.X (simple_batspp.py) & kcov
## SCRIPT_NAME : batspp_report_final.py

""" 

"""

import os
import sys

IPYNB = ".ipynb"
BATSPP = ".batspp"
BATS = ".bats"
TXT = ".txt"

BATSPP_STORE = r"batspp-only"
BATS_STORE = r"bats-only"
TXT_STORE = r"txt-reports"
KCOV_STORE = r"kcov-output"

files = os.listdir(r"./")
#ARG = sys.argv[1]

# 1) Identifying .ipynb files
i = 1
ipynb_array = []
print("\n=== BATSPP REPORT GENERATOR (simple_batspp.py) ===\n")

for file in files:
    is_ipynb = file.endswith(IPYNB)
    if is_ipynb:
        print(f"JUPYTER TESTFILE FOUND [{i}]: {file}")
        ipynb_array += [file]
        i += 1

print(f"\nTOTAL JUPYTER FILE FOUND: {i}\n")

# 2) Generating .batspp files from .ipynb files

i = 1
print(f"\n=== GENERATING BATSPP FILES ===\n")

for testfile in files:
    is_ipynb = testfile.endswith(IPYNB)
    if is_ipynb:
        print (f"\nIPYNB TESTFILE [{i}]: {testfile}\n")
        os.system(f"./jupyter_to_batspp.py ./{testfile} --output ./{BATSPP_STORE}/{testfile.replace(IPYNB, BATSPP)}")
        i += 1

ipynb_c = i - 1

# 3) Executing batspp files & storing them as bats
print ("\n<=== REPORT GENERATION ===>\n")
i = 1
print ("\n[=== BATS GENERATED ===]") 

for batsppfile in files:
    is_batspp = batsppfile.endswith(BATSPP)

    if is_batspp:
        bats_from_batspp = batsppfile.replace(BATSPP, BATS)
        kcov_folder = batsppfile.replace(BATSPP, "")
        print(f"\nBATSPP FILE DETECTED [{i}]: {batsppfile}\n")
        os.system(f"./simple_batspp.py ./{BATSPP_STORE}/{batsppfile} --output ./{BATS_STORE}/{bats_from_batspp}")
