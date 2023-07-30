#!/bin/bash
#
# summary_stats.bash works in the following manner:
# 1) ./batspp_report.py -k (regenerates all KCOV dirs and output in HTML)
# 2) [optional] ./kcov_result.py --list --export (returns result according to the KCOV outputs) 
# 3) Output of the process is also stored in ./summary_stats.txt
#

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Change into testing script directory (e.g., ~/shell-scripts/tests)
cd "$(dirname "$0")"

# Derive name for output file
# Note: Uses unique output subdir under ~/temp (or $BATSPP_OUTPUT).
# Likewise, uses unique temp subdir under /tmp  (or $BATSPP_TEMP).
timestamp=$(date '+%d%b%y-%H%M')
TMP=${TMP:-/tmp}
BATSPP_OUTPUT="${BATSPP_TEMP:-"$HOME/temp/BatsPP-$timestamp"}"
BATSPP_TEMP="${BATSPP_TEMP:-"$TMP/BatsPP-$timestamp"}"
mkdir --parents "$BATSPP_OUTPUT" "$BATSPP_TEMP"
echo "FYI: Using $BATSPP_OUTPUT for ouput and $BATSPP_TEMP for temp. files"

## TEMP: Enable flag for deleting aliases in order to force fail some tests
## NOTE: this enables a bunch of alias removals in all-tomohara-aliases-etc.bas
## export DIR_ALIAS_HACK=1

# Run the set of alias tests, making sure Tom's aliases are defined
OUTPUT_DIR="$BATSPP_OUTPUT" TEMP_BASE="$BATSPP_TEMP" python3 ./batspp_report.py --txt --definitions ../all-tomohara-aliases-etc.bash

## NOTE: kcov is not critical, so it is not run as part of workflow tests
## TODO: python3 ./kcov_result.py --list --summary --export | tee summary_stats.txt
