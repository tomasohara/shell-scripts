#! /usr/bin/env bash
#
# Outputs current date in format DDmmmYY
#
# note: Used in crontab, so not a function or alias.
#

# Parse command line arguments
date_format='+%d%b%y'
show_usage=0
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [[ "$moreoptions" == "1" ]]; do
    # TODO : add real options
    if [[ "$1" == "--trace" ]]; then
        set -o xtrace
    elif [[ "$1" == "--help" ]]; then
        show_usage=1
    elif [[ "$1" == "--with-hhmm" ]]; then
        date_format="${date_format}_%H%M"
    elif [[ ("$1" == "--") || ("$1" == "-") ]]; then
        shift
        break
    else
        echo "Error: Unknown option: $1";
        show_usage=1
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# Show usage statement if requested or bad option
if [[ "$show_usage" == "1" ]]; then
    script=$(basename "$0")
    echo "Usage: $0 [--with-hhmm] [--format] [--help] [--trace] [--| -]"
    echo ""
    echo "Examples:"
    echo 
    echo "$0"
    echo ""
    echo "$script --with-hhmm"
    echo ""
    exit
fi

date "$date_format" | perl -pe 's/.*/\L$&/;'
