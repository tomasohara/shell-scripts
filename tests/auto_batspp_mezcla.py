#! /usr/bin/env python

#| NOTE: USES batspp 1.X.X (simple_batspp.py), mezcla & kcov || MAY NOT WORK PROPERLY ON FIRST RUN
## SCRIPT_NAME : auto_batspp.py
#| BUG: NO EXECUTION ON FIRST TRY
""" 
    TEST AUTOMATION & REPORT GENERATION FOR IPYNB TEST FILES (FOR BATSPP)
    OPTIONS:
        -n = No report is generated, only shows available ipynb files
        -t = Generates .txt reports, stored at ./txt-reports
        -k = Generates KCOV reports, stored at ./kcov-output
"""
from mezcla import glue_helpers as gh
from mezcla import system as msy
import sys

IPYNB = ".ipynb"
BATSPP = ".batspp"
BATS = ".bats"
TXT = ".txt"

BATSPP_STORE = "batspp-only"
BATS_STORE = "bats-only"
TXT_STORE = "txt-reports"
KCOV_STORE = "kcov-output"

ESSENTIAL_DIRS = [BATSPP_STORE, BATS_STORE, KCOV_STORE, TXT_STORE]

ESSENTIAL_DIRS_present = all(gh.file_exists(dir) for dir in ESSENTIAL_DIRS)

files = msy.read_directory("./")

# 0) CHECKING IF THE DIRECTORY EXISTS
# if BATSPP_STORE and BATS_STORE and TXT_STORE and KCOV_STORE not in files:
if not ESSENTIAL_DIRS_present:
    gh.create_directory(BATS_STORE)
    gh.create_directory(BATSPP_STORE)
    gh.create_directory(TXT_STORE)
    gh.create_directory(KCOV_STORE)
    
filesys_bpp = msy.read_directory("./batspp-only/")
filesys_bats = msy.read_directory("./bats-only")

ARG = str(sys.argv)
batspp_count = 0

# 1) Identifying .ipynb files

i = 1
ipynb_array = []
print("\n=== BATSPP REPORT GENERATOR (simple_batspp.py / BATSPP 1.5.X) ===\n")

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
        batspp_from_ipynb = testfile.replace(IPYNB, BATSPP)
        print (f"\nIPYNB TESTFILE [{i}]: {testfile} => {batspp_from_ipynb}\n")
        gh.run(f"./jupyter_to_batspp.py ./{testfile} --output ./{BATSPP_STORE}/{batspp_from_ipynb}")
        i += 1

ipynb_count = i - 1

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
            kcov_folder = gh.remove_extension(batsppfile, BATSPP)
            
            print(f"\nBATSPP FILE DETECTED [{i}]: {batsppfile} => {bats_from_batspp}\n")
            
            if "-t" in ARG:
                gh.run(f"./simple_batspp.py ./{BATSPP_STORE}/{batsppfile} --output ./{TXT_STORE}/{txt_from_batspp}")
                print (f"REPORT STORED AT ./{TXT_STORE}/{txt_from_batspp}")
                i += 1
            else:
                gh.run(f"./simple_batspp.py ./{BATSPP_STORE}/{batsppfile} --output ./{BATS_STORE}/{bats_from_batspp}")
                i += 1
                
                if "-k" in ARG:
                    print(f"\n[GENERATING KCOV REPORTS FOR {bats_from_batspp}]:\n")
                    gh.run(f"kcov ./{KCOV_STORE}/{kcov_folder}/ bats ./{BATS_STORE}/{bats_from_batspp}")
                
    batspp_count = i - 1 

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
faulty_count = ipynb_count - batspp_count

print(f"\n======================================================")
print(f"SUMMARY STATISTICS:\n")
print(f"IPYNB FILES PRESENT: {ipynb_count}")
print(f"BATSPP FILES GENERATED: {batspp_count if '-n' or '-t' not in ARG else 'NaN'}")
print(f"NO. OF FAULTY TESTFILES: {faulty_count if 'n' or 't' not in ARG else 'NaN'}")
print(f"\nFAULTY TESTFILES:")
if faulty_count == 0:
    print ("NaN")
else: 
    for tf in error_testfiles:  
        print(f">> {tf}")
print(f"======================================================")

# #print(f"ALL ARGS: {ARG.pop()}") 
