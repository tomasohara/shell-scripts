#! /bin/bash
#
# kdiff.sh: Invokes kdiff over the files making sure unix paths resolved to windows.
#
# NOTE: Assumes kdiff3 executable is in path.
# TODO:
# - Add support for Unix.
# - Check for default installation directory (e.g., C:\Program Files\KDiff3).
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## set -o xtrace
## set -o verbose

# TODO: Parse command-line options
#
kdiff="kdiff3"
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--fubar" ]; then
	echo "fubar";
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
#
# TODO: Show usage statement
#
if [ "$2" = "" ]; then
    echo ""
    echo "usage: `basename $0` [options]"
    echo ""
    echo "ex: `basename $0` whatever"
    echo ""
    exit
fi
file1="$1"
file2="$2"
if [ "$OSTYPE" = "cygwin" ]; then
    file1=`cygpath -w "$file1"`
    file2=`cygpath -w "$file2"`
    kdiff="cygstart $kdiff"
fi

# Invoke kdiff
$kdiff "$file1" "$file2" &

