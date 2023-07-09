#!/bin/bash

# summary_stats.bash works in the following manner:
# 1) ./batspp_report.py -k (regenerates all KCOV dirs and output in HTML)
# 2) [optional] ./kcov_result.py --list --export (returns result according to the KCOV outputs) 
# 3) Output of the process is also stored in ./summary_stats.txt

cd "$(dirname "$0")"

TEMP="${TEMP:-$HOME/temp}"
mkdir --parents "$TEMP"

# Run the set of alias tests, making sure Tom's aliases are defined
# Note: 
OUTPUT_DIR=$TEMP python3 ./batspp_report.py --txt --definitions ../all-tomohara-aliases-etc.bash

## NOTE: kcov is not critical, so it is not run as part of workflow tests
## TODO: python3 ./kcov_result.py --list --summary --export | tee summary_stats.txt
