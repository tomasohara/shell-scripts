#! /bin/bash
#
# kdiff.sh: Invokes kdiff3 over the files making sure unix paths resolved to windows
# if under Cygwin.
#
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## set -o xtrace
## set -o verbose

# Parse command-line options
#
kdiff="kdiff3"
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
show_usage=0
while [ "$moreoptions" == "1" ]; do
    if [ "$1" == "--trace" ]; then
	set -o xtrace;
    elif [ "$1" == "--help" ]; then
	show_usage=1
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
#
# Show usage statement if need be
#
if [[ ("$2" == "") && ("$show_usage" == "0") ]]; then
    echo ""
    echo "Error: missing filename"
    show_usage=1
fi
if [ "$show_usage" == "1" ]; then
    script=$(basename "$0")
    echo ""
    echo "Usage: $script [options] filename1 filename2"
    echo "    options: [--trace] [--help]"
    echo ""
    echo "Example:"
    echo "    $0 diff.sh do_diff.sh"
    echo ""
    exit
fi
file1="$1"
file2="$2"
if [ "$OSTYPE" == "cygwin" ]; then
    file1=$(cygpath -w "$file1")
    file2=$(cygpath -w "$file2")
    kdiff="cygstart $kdiff"
fi

# Invoke kdiff
$kdiff "$file1" "$file2" 2>| "$TMP/kdiff-$$.log" &
