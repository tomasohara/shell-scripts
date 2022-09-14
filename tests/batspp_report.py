#! /usr/bin/env python

# batspp_report.py
# NOTE: USES BATSPP 1.5 (simple_batspp.py) | DIRECTORY NOT SPECIFIED
""" SELECTS AN IPYNB FILE,
    USES jupyter_to_batspp.py TO GENERATE BATSPP FILE,
    EXECUTES BATSPP FILE,
    REPORTS STORED AT ./tests/batspp-reports
"""

import os

TEST_PATH = "./"
IPYNB_EXTENSION = ".ipynb"
BATSPP_EXTENSION = ".batspp"
i = 1

files_TEST_PATH = os.listdir(TEST_PATH)

# 1) IDENTIFY IPYNB FILES
all_testfiles = []
print("\n=== BATSPP REPORT GENERATOR (simple_batspp.py) ===\n")

for file in files_TEST_PATH:
    is_ipynb = file.endswith(IPYNB_EXTENSION)
    if is_ipynb:
        #os.system(f"batspp {file} --output {REPORT_PATH}/REPORT-{file}.txt")
        print(f"JUPYTER TESTFILE FOUND [{i}]: {file}")
        all_testfiles += [file]
        i += 1

print(f"\nTOTAL JUPYTER FILE FOUND: {i}\n")


# 2) GENERATING BATSPP FILES FROM IPYNB FILES | ALSO NOTIFY FOR TESTS WITH ERRORS
print(f"\n=== GENERATING BATSPP FILES ===\n")
i = 1

for testfile in files_TEST_PATH:
    is_ipynb = testfile.endswith(IPYNB_EXTENSION)
    if is_ipynb:
        print (f"\nIPYNB TESTFILE [{i}]: {testfile}\n")
        os.system(f"./jupyter_to_batspp.py ./{testfile}")
        i += 1

ipynb_c = i - 1

# 3) DISPLAY AND EXECUTE BATSPP FILES | ALSO NOTIFY FOR ANY ERROR IN TESTFILE     
print(f"\n\n***** BATSPP GENERATED *****\n")
i = 1

for batsfile in files_TEST_PATH:
    is_batspp = batsfile.endswith(BATSPP_EXTENSION)

    if is_batspp:
        bats_RPT = batsfile.replace(".batspp", ".txt")
        print(f"\nBATSPP FILE DETECTED [{i}]: {batsfile}\n")
        os.system(f"./simple_batspp.py ./{batsfile} --output ./batspp-reports/{bats_RPT}")
        i += 1
batspp_c = i - 1

# 4) MENTION ANY ERROR IPYNB TESTS
working_testfiles = []

for file in files_TEST_PATH:
    is_batspp = file.endswith(BATSPP_EXTENSION)
    is_ipynb = file.endswith(IPYNB_EXTENSION)

    if is_batspp:
        BI_check = [file.replace(".batspp", ".ipynb")]
        working_testfiles += BI_check


# 5) SUMMARY STATISTICS

set_wt = set(working_testfiles)
error_testfiles = [tf for tf in all_testfiles if tf not in set_wt]

print(f"\n======================================================")
print(f"SUMMARY STATISTICS:\n")
print(f"IPYNB FILES PRESENT: {ipynb_c}")
print(f"BATSPP FILES GENERATED: {batspp_c}")
print(f"NO. OF FAULTY TESTFILES: {ipynb_c - batspp_c}")
print(f"\nFAULTY TESTFILES:")
for tf in error_testfiles:
    print(f">> {tf}")
print(f"======================================================")
