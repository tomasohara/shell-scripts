#! /usr/bin/env bash
#
# Simple script with homegrown command-line parsing used to solicit a
# solution via getopt/getopts by ChatGPT. See
#    chatgpt-get-long-options-parsing.bash
#

# Display command-line usage
function usage(){
    local script
    script=$(basename "$0")
    echo ""
    echo "Usage: $script [options] filename1 filename2"
    echo "    options: [--fubar | -f] [--help | -h] [--trace | -t] [--verbose | -v]"
    echo ""
    echo "Example:"
    echo "    $0 --fubar"
    echo ""
}

# Parse options
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
fubar=0
level=0
show_usage=0
while [ "$moreoptions" == "1" ]; do
    if [[ ("$1" == "--fubar") || ("$1" == "-f") ]]; then
        fubar=1
    elif [[ ("$1" == "--help") || ("$1" == "-h") ]]; then
        show_usage=1
    elif [[ ("$1" == "--level") || ("$1" == "-l") ]]; then
        level="$2"
        shift
    elif [[ ("$1" == "--trace") || ("$1" == "-t") ]]; then
        set -o xtrace
    elif [[ ("$1" == "--verbose") || ("$1" == "-v") ]]; then
        set -o verbose
    elif [[ ("$1" == "--") || ("$1" == "-") ]]; then
        break
    else
        echo "ERROR: Unknown option: $1";
        show_usage=1
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# Show usage
if [ "$show_usage" == "1" ]; then
   usage
   exit
fi

# Show result
echo "fubar=$fubar"
echo "level=$level"
set -o | egrep '^(xtrace|verbose)\b'
