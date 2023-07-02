#!/bin/bash

# summary_stats.bash works in the following manner:
# 1) ./batspp_report.py -k (regenerates all KCOV dirs and output in HTML)
# 2) ./kcov_result.py --list --export (returns result according to the KCOV outputs) 
# 3) Output of the process is also stored in ./summary_stats.txt
# BUG: Might fail on first run

## OLD: ./batspp_report.py -k && ./kcov_result.py --list --summary --export | tee summary_stats.txt

cd $(dirname "$0")

## TODO by Aviyan: fix this to produce a simple summary as requested several
## times in email. (This was both to you and Bruno a while back and then more
## recently to you and Tana.)
python3 ./batspp_report.py --txt

## NOTE: kcov is not critical and moreover is just serving to slow us down!
## TODO: python3 ./kcov_result.py --list --summary --export | tee summary_stats.txt
