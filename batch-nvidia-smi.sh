#! /bin/bash
#
# Run nvidia-smi in background N times with a delay of S seconds each.
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
    base=$(basename "$0")
    echo ""
    ## TODO: add option or remove TODO placeholder
    echo "Usage: $0 [--TODO] [--trace] [--help] [--] [num-times] [pause-time]"
    echo ""
    echo "Examples:"
    echo ""
    echo "\"$base\" 1200 0.5"
    echo ""
    echo "one_day_in_secs=(24 * 3600)"
    echo "\"$base\" \$one_day_in_secs 1 > _batch-nvidia-smi.log &"
    echo ""
    echo "Notes:"
    echo "- The -- option is to use default options and to avoid usage statement."
    ## TODO: add more notes
    ## echo ""
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

for (( i=0; i<$n; i++ )); do
    nvidia-smi
    sleep $s
done
