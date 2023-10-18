#!/bin/bash
#
# summary_stats.bash works in the following manner [OLD]:
# 1) ./batspp_report.py -k (regenerates all KCOV dirs and output in HTML)
# 2) [optional] ./kcov_result.py --list --export (returns result according to the KCOV outputs) 
# 3) Output of the process is also stored in ./summary_stats.txt
#
# Warning:
# - This should not be run under an admin-like account (e.g., root or power user), because the tests might inadvertantly delete files.
# - It is safest to use a separate testing account with minimal permissions.
#

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Help Message
display_help() {
	echo "Usage: $0 [-f]"
	echo "	-o	Shows output log (summary_stats.log)"
	echo "	-x	Force execution even if admin-like user"
	echo "	-h	Displays this help message"
}

# Applying options for output log
output_log=false

while getopts "ohx" option; do
	case $option in
		o)
			output_log=true
			;;
		x)
			force_opt=true
			;;
		h)
			display_help
			exit 0
			;;
		\?)
			echo  "Invalid option: -$OPTARG" >&2
			display_help
			exit 1
			;;
	esac
done

# Change into testing script directory (e.g., ~/shell-scripts/tests)
cd "$(dirname "$0")"

# Derive name for output file
# Note: Uses unique output subdir under ~/temp (or $BATSPP_OUTPUT).
# Likewise, uses unique temp subdir under /tmp  (or $BATSPP_TEMP).
timestamp=$(date '+%d%b%y-%H%M')
TMP=${TMP:-/tmp}
BATSPP_OUTPUT="${BATSPP_OUTPUT:-"$HOME/temp/BatsPP-$timestamp"}"
BATSPP_TEMP="${BATSPP_TEMP:-"$TMP/BatsPP-$timestamp"}"
BATSPP_FORCE="${BATSPP_FORCE:-1}"
mkdir --parents "$BATSPP_OUTPUT" "$BATSPP_TEMP"
echo "FYI: Using $BATSPP_OUTPUT for ouput and $BATSPP_TEMP for temp. files"

## TEMP: Enable flag for deleting aliases in order to force fail some tests
## NOTE: this enables a bunch of alias removals in all-tomohara-aliases-etc.bas
## export DIR_ALIAS_HACK=1

# Run the set of alias tests, making sure Tom's aliases are defined
# notes: disables SC2086: Double quote to prevent globbing and word splitting.
# BATSPP_REPORT_OPTS can be used to run coverage tests (e.g., --kcov) instead
# of the regular report (--txt).
# 
## OLD: BATSPP_REPORT_OPTS=${BATSPP_REPORT_OPTS:-"--txt --definitions ../all-tomohara-aliases-etc.bash"}

## OLD APPROACH
## shellcheck disable=SC2086
# OUTPUT_DIR="$BATSPP_OUTPUT" TEMP_BASE="$BATSPP_TEMP" python3 ./batspp_report.py $BATSPP_REPORT_OPTS
# batspp_result="$?"

## NEW APPROACH: Using force option
# Run under force mode when -f option enabled
if $force_opt; then
	echo "Force option (-f) enabled"
	FORCE_RUN="$BATSPP_FORCE" OUTPUT_DIR="$BATSPP_OUTPUT" TEMP_BASE="$BATSPP_TEMP" python3 ./batspp_report.py $BATSPP_REPORT_OPTS
	batspp_result="$?"
else
	OUTPUT_DIR="$BATSPP_OUTPUT" TEMP_BASE="$BATSPP_TEMP" python3 ./batspp_report.py $BATSPP_REPORT_OPTS
	batspp_result="$?"
fi

## NOTE: kcov is not critical, so it is not run as part of workflow tests
## TODO: python3 ./kcov_result.py --list --summary --export | tee summary_stats.txt

# Generate output log when -o option enabled
if $output_log; then
	grep -B20 "^not ok" "$(find "$BATSPP_OUTPUT" -name '*outputpp.out')" | less -p "not ok" > summary_stats.log
fi

# *** Note: the result needs to be that of alias tests (i.e., batspp_report.py)
exit "$batspp_result"
