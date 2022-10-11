#! /usr/bin/env python

#| NOTE: USES batspp 1.X.X (simple_batspp.py) & kcov || MAY NOT WORK PROPERLY ON FIRST RUN
## SCRIPT_NAME : auto_batspp.py
#| BUG: NO EXECUTION ON FIRST TRY
""" 
    TEST AUTOMATION & REPORT GENERATION FOR IPYNB TEST FILES (FOR BATSPP)
    OPTIONS:
        -n = No report is generated, only shows available ipynb files
        -t = Generates .txt reports, stored at ./txt-reports
        -k = Generates KCOV reports, stored at ./kcov-output
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
filesys_bpp = os.listdir(r"./batspp-only/")
filesys_bats = os.listdir(r"./bats-only")


ARG = str(sys.argv)
bpp_c = 0
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
print ("\n\n==========BATS GENERATED==========\n") 
i = 1   

if "-n" in ARG:
    print(">> SKIPPING BATSPP CHECK (-n ARGUMENT PROVIDED)\n")
else:
    for batsppfile in filesys_bpp:
        is_batspp = batsppfile.endswith(BATSPP)

        if is_batspp:
            bats_from_batspp = batsppfile.replace(BATSPP, BATS)
            txt_from_batspp = batsppfile.replace(BATSPP, TXT)
            kcov_folder = batsppfile.replace(BATSPP, "")
            
            print(f"\nBATSPP FILE DETECTED [{i}]: {batsppfile}\n")
            if "-t" in ARG:
                os.system(f"./simple_batspp.py ./{BATSPP_STORE}/{batsppfile} --output ./{TXT_STORE}/{txt_from_batspp}")
                print (f"\nREPORT STORED AT ./{TXT_STORE}/{txt_from_batspp}")
                i += 1
            else:
                os.system(f"./simple_batspp.py ./{BATSPP_STORE}/{batsppfile} --output ./{BATS_STORE}/{bats_from_batspp}")
                i += 1
                
                if "-k" in ARG:
                    print(f"\n[GENERATING KCOV REPORTS FOR {bats_from_batspp}]:\n")
                    os.system(f"kcov ./{KCOV_STORE}/{kcov_folder}/ bats ./{BATS_STORE}/{bats_from_batspp}")
                
    bpp_c = i - 1 

# 4) Mentioning any errors in ipynb testfiles
working_testfiles = []

for file in filesys_bpp:
    is_batspp = file.endswith(BATSPP)

    if is_batspp:
        BI_check = [file.replace(".batspp", ".ipynb")]
        working_testfiles += BI_check

# 5) Summary Statistics
set_wt = set(working_testfiles)
error_testfiles = [tf for tf in ipynb_array if tf not in set_wt]
faulty_c = ipynb_c - bpp_c

print(f"\n======================================================")
print(f"SUMMARY STATISTICS:\n")
print(f"IPYNB FILES PRESENT: {ipynb_c}")
print(f"BATSPP FILES GENERATED: {bpp_c if '-n' or '-t' not in ARG else 'NaN'}")
print(f"NO. OF FAULTY TESTFILES: {faulty_c if 'n' or 't' not in ARG else 'NaN'}")
print(f"\nFAULTY TESTFILES:")
if faulty_c == 0:
    print ("NaN")
else: 
    for tf in error_testfiles:  
        print(f">> {tf}")
print(f"======================================================")

#print(f"ALL ARGS: {ARG.pop()}") 
