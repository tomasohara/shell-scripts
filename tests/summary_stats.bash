#!/bin/bash
#
# summary_stats.bash works in the following manner [OLD]:
# 1) ./batspp_report.py -k (regenerates all KCOV dirs and output in HTML)
# 2) [optional] ./kcov_result.py --list --export (returns result according to the KCOV outputs)
# 3) Output of the process is also stored in ./summary_stats.txt
#
# Warning:
# - This should not be run under an admin-like account (e.g., root or power user), because the tests might inadvertently delete files.
# - It is safest to use a separate testing account with minimal permissions.
#

# NEW: Initializing Options
output=0
force=0
help=0
trace=0
verbose=0
DEBUG_SCRIPT=$([ "${DEBUG_SCRIPT:-0}" -eq 1 ] && echo true || echo false)

# Help Message
display_help() {
    echo "Usage: $0 [filename]"
    echo "    -o    --output    Shows output log (summary_stats.log)"
    echo "    -f    --force     Force execution even if admin-like user"
    echo "    -t    --trace     Enables bash-regular tracing"
    echo "    -v    --verbose   Enables verbose tracing"
    echo "    -h    --help      Displays this help message"
}

# Using getopt for argument parsing
OPT_TEMP=$(getopt -o ofhtv --long output,force,help,trace,verbose -n "$0" -- "$@")
if [ $? != 0 ]; then
    echo "Terminating..." >&2
    exit 1
fi
$DEBUG_SCRIPT && echo "OPT_TEMP=$OPT_TEMP"

# Assigning each distinct argument to $1, $2, ...
eval set -- "$OPT_TEMP"

while true ; do
    $DEBUG_SCRIPT && echo "\$1=$1"

    case "$1" in
        -o|--output)
            output=1
            shift
            ;;
        -f|--force)
            force=1
            shift
            ;;
        -h|--help)
            help=1
            shift
            exit 0
            ;;
        -t|--trace)
            trace=1
            shift
            ;;
        -v|--verbose)
            verbose=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal Error."
            exit 1
            ;;
    esac
done

# OPTION I: Bash Regular Tracing
if [ "$trace" == "1" ]; then
    set -o xtrace
fi

# OPTION II: Verbose Tracing
if [ "$verbose" == "1" ]; then
    set -o verbose
fi

# OPTION III: Show Usage (Help)
if [ "$help" == "1" ]; then
    display_help
fi

# OPTION 
BATSPP_REPORT_OPTS="--txt --definitions ../all-tomohara-aliases-etc.bash"
batspp_result=0

# Likewise, uses a unique temp subdir under /tmp (or $BATSPP_TEMP).
timestamp=$(date '+%d%b%y-%H%M')
TMP=${TMP:-/tmp}
BATSPP_OUTPUT="${BATSPP_OUTPUT:-"$HOME/temp/BatsPP-$timestamp"}"
BATSPP_TEMP="${BATSPP_TEMP:-"$TMP/BatsPP-$timestamp"}"
BATSPP_FORCE="${BATSPP_FORCE:-1}"
mkdir -p "$BATSPP_OUTPUT" "$BATSPP_TEMP"

echo "FYI: Using $BATSPP_OUTPUT for output and $BATSPP_TEMP for temp. files"
echo "Force Run: $force"

# NEW APPROACH: Using the force option
# Run under force mode when -f option is enabled
if [ "$force" == "1" ]; then
    echo "Force option (-f) enabled"
    FORCE_RUN="$BATSPP_FORCE" OUTPUT_DIR="$BATSPP_OUTPUT" TEMP_BASE="$BATSPP_TEMP" python3 ./batspp_report.py $BATSPP_REPORT_OPTS
    batspp_result="$?"
else
    OUTPUT_DIR="$BATSPP_OUTPUT" TEMP_BASE="$BATSPP_TEMP" python3 ./batspp_report.py $BATSPP_REPORT_OPTS
    batspp_result="$?"
fi

# NOTE: kcov is not critical, so it is not run as part of workflow tests
# TODO: python3 ./kcov_result.py --list --summary --export | tee summary_stats.txt

# Generate an output log when -o option is enabled
if [ "$output" == "1" ]; then
    grep -B20 "^not ok" "$(find "$BATSPP_OUTPUT" -name '*outputpp.out')" | less -p "not ok" > summary_stats.log
fi

# The result needs to be that of alias tests (i.e., batspp_report.py)
exit "$batspp_result"



## OLD APPROACH / TIDY UP CODE

## OLD
# # Set bash regular and/or verbose tracing
# if [ "${TRACE:-0}" = "1" ]; then
#     set -o xtrace
# fi
# if [ "${VERBOSE:-0}" = "1" ]; then
#     set -o verbose
# fi

## OLD
# # Help Message
# display_help() {
#     echo "Usage: $0 [-f]"
#     echo "    -o    Shows output log (summary_stats.log)"
#     echo "    -x    Force execution even if admin-like user"
#     echo "    -h    Displays this help message"
# }

# Initializing variables
# output_log=false
# force_opt=false

# # Applying options for output log
# while getopts "ohx" option; do
#     case $option in
#         o)
#             output_log=true
#             ;;
#         x)
#             force_opt=true
#             ;;
#         h)
#             display_help
#             exit 0
#             ;;
#         \?)
#             echo "Invalid option: -$OPTARG" >&2
#             display_help
#             exit 1
#             ;;
#     esac
# done

# # Change into the testing script directory (e.g., ~/shell-scripts/tests)
# cd "$(dirname "$0")"

# # Derive name for output file
# # Note: Uses unique output subdir under ~/temp (or $BATSPP_OUTPUT).
# # Likewise, uses a unique temp subdir under /tmp (or $BATSPP_TEMP).
# timestamp=$(date '+%d%b%y-%H%M')
# TMP=${TMP:-/tmp}
# BATSPP_OUTPUT="${BATSPP_OUTPUT:-"$HOME/temp/BatsPP-$timestamp"}"
# BATSPP_TEMP="${BATSPP_TEMP:-"$TMP/BatsPP-$timestamp"}"
# BATSPP_FORCE="${BATSPP_FORCE:-1}"
# mkdir -p "$BATSPP_OUTPUT" "$BATSPP_TEMP"
# echo "FYI: Using $BATSPP_OUTPUT for output and $BATSPP_TEMP for temp. files"
# echo "Force Run: $force_opt"

# # Run the set of alias tests, making sure Tom's aliases are defined
# # Notes: Disables SC2086: Double quote to prevent globbing and word splitting.
# # BATSPP_REPORT_OPTS can be used to run coverage tests (e.g., --kcov) instead
# # of the regular report (--txt).
# # 
# # OLD APPROACH
# # shellcheck disable=SC2086
# # OUTPUT_DIR="$BATSPP_OUTPUT" TEMP_BASE="$BATSPP_TEMP" python3 ./batspp_report.py $BATSPP_REPORT_OPTS
# # batspp_result="$?"

# # NEW APPROACH: Using the force option
# # Run under force mode when -f option is enabled
# if $force_opt; then
#     echo "Force option (-f) enabled"
#     FORCE_RUN="$BATSPP_FORCE" OUTPUT_DIR="$BATSPP_OUTPUT" TEMP_BASE="$BATSPP_TEMP" python3 ./batspp_report.py $BATSPP_REPORT_OPTS
#     batspp_result="$?"
# else
#     OUTPUT_DIR="$BATSPP_OUTPUT" TEMP_BASE="$BATSPP_TEMP" python3 ./batspp_report.py $BATSPP_REPORT_OPTS
#     batspp_result="$?"
# fi

# # NOTE: kcov is not critical, so it is not run as part of workflow tests
# # TODO: python3 ./kcov_result.py --list --summary --export | tee summary_stats.txt

# # Generate an output log when -o option is enabled
# if $output_log; then
#     grep -B20 "^not ok" "$(find "$BATSPP_OUTPUT" -name '*outputpp.out')" | less -p "not ok" > summary_stats.log
# fi

# # The result needs to be that of alias tests (i.e., batspp_report.py)
# exit "$batspp_result"
