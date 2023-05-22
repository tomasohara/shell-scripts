#! /bin/bash
#
# sync-sync-loop.sh: repeatedly invoke 'sync' in background loop in order
# to work around problem with battery-based power glitches (i.e., abrupt
# shutdowns).
#
# TODO:
# - Run this as a cron job.
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## set -o verbose

function usage() {
    base=$(basename "$0");
    echo "";
    echo "usage: $0 [options]";
    echo "options: [--delay n] [--help] [--trace]  [--]";
    echo "";
    # TODO: two examples; also add alias to tomohara.bash
    echo "examples:"
    echo ""
    echo "$0 --"
    echo ""
    echo "$base --delay 15 >| /tmp/$base.$$.log &"
    echo ""
    return
}

# Parse command-line options
#
delay=60
# TODO: show_usage=(( "$1" != "" ))
show_usage=0; if [ "$1" = "" ]; then show_usage=1; fi
more_options=0; case "$1" in -*) more_options=1 ;; esac
# TODO: add option for maximum number of iterations 
while [ "$more_options" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace
    elif [ "$1" = "--help" ]; then
	show_usage=1
	break
    elif [ "$1" = "--delay" ]; then
	delay="$2"
	shift
    elif [ "$1" = "--" ]; then
	break
    elif [ "$1" = "" ]; then
	echo "Warning: internal error in $0"
	break
    else
	echo "ERROR: Unknown option: $1"
	show_usage=1
    fi
    shift
    more_options=0; case "$1" in -*) more_options=1 ;; esac
done
if [ "$show_usage" = "1" ]; then
    usage
    exit
fi

# Issue disk cache synchronization and then sleep for a minute
## TODO: add other commands (e.g., sensors)
synch_count=0
echo "Running file system sync every $delay seconds"
while [ 1 ]; do
      let synch_count++
      echo "synching (iteration $synch_count)"
      sync
      sync
      sleep $delay
done
