#! /bin/bash
#
# Run nvidia-smi in background N times with a delay of N seconds each.
#
# Note:
# - The nvidia-smi utility allows for delay via --loop= or --loop-ms, but this
#   this script documents the usage better.
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## DEBUG: set -o verbose

# Show usage statement
# TODO: convert into a function that get invoked with $1 is empty or --help
# in $@.
# NOTE: See sync-loop.sh for an example.
#
if [ "$1" = "" ]; then
    script=$(basename "$0")
    base=$(basename "$script" sh)
    echo ""
    echo "Usage: $script [--trace] [--help] [--] [num-times] [pause-time]"
    echo ""
    echo "Examples:"
    echo "- Simple"
    echo "  $0 1200 0.5"
    echo ""
    echo "- Advanced:"
    echo "  date_yyyy_mm_dd_hhmm=\"$(date '+%Y-%m-%d_%H%M')\""
    echo "  log_file=\"$base-\$date_yyyy_mm_dd_hhmm.log\""
    echo "  let one_day_in_secs=(24 * 3600)"
    echo "  let delay_time=60"
    echo "  let num_times=(one_day_in_secs / delay_time)"
    echo "  $script \$num_times \$delay_time > \$log_file &"
    # TODO: rework calculation using bc or perlcalc.perl???
    # alt 1: echo "  num_times=\$(echo \"\$one_day_in_secs * 1.0 / \$delay_time)" | bc -l"
    # alt 2: echo "  num_times=\$(echo \"round(\$one_day_in_secs * 1.0 / \$delay_time)\" | perlcalc.perl -integer)"
    echo ""
    echo "Notes:"
    echo "- The -- option is to use default options and to avoid usage statement."
    echo "- The advanced example use bash interger math."
    echo "- Both examples assumes the script name doesn't require quoting."
    echo ""
    exit
fi

# Parse command-line options
# TODO: set getopt-type utility
#
n=120
s=0.5
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    # TODO : add real options
    if [ "$1" = "--trace" ]; then
	set -o xtrace
    elif [ "$1" = "--fubar" ]; then
	echo "fubar"
    elif [ "$1" = "--" ]; then
	break
    else
	echo "ERROR: Unknown option: $1";
	exit
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
#
if [ "$1" != "" ]; then n="$1"; fi
if [ "$2" != "" ]; then s="$2"; fi

for (( i=0; i<n; i++ )); do
    nvidia-smi
    sleep "$s"
done
