#!/bin/bash

# summary_stats.bash works in the following manner:
# 1) ./batspp_report.py -k (regenerates all KCOV dirs and output in HTML)
# 2) ./kcov_result.py --list --export (returns result according to the KCOV outputs) 
# 3) Output of the process is also stored in ./summary_stats.txt
# BUG: Might fail on first run

## OLD: ./batspp_report.py -k && ./kcov_result.py --list --summary --export | tee summary_stats.txt

cd $(dirname "$0")
# python3 ./batspp_report.py -k && python3 ./kcov_result.py --list --summary --export | tee summary_stats.txt
python3 ./batspp_report.py > /dev/null 2>&1
python3 ./batspp_report.py -k && python3 ./kcov_result.py --list --summary --export | tee summary_stats.txt