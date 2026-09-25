#! /usr/bin/env bash
#
# kdiff.sh: Invokes kdiff3 over the files making sure unix paths resolved to windows
# if under Cygwin.
#
## UPDATE 2026-09-25: fix for file2 resolution by GPT-5.6 Terra and DRY_RUN, etc.

# Set bash regular and/or verbose tracing
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#
if [ "${DEBUG_LEVEL:-0}" -ge 4 ]; then
    echo "$0 $*"
fi
if [[ "${TRACE:-0}" == "1" ]]; then
    set -o xtrace
fi
if [[ "${VERBOSE:-0}" == "1" ]]; then
    set -o verbose
fi
if [[ "${STRICT:-0}" == "1" ]]; then
    set -euo pipefail
fi
DRY_RUN="${DRY_RUN:-0}"

# Parse command-line options
#
kdiff="kdiff3"
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
show_usage=0
while [ "$moreoptions" == "1" ]; do
    if [ "$1" == "--trace" ]; then
        set -o xtrace;
    elif [ "$1" == "--cmd" ]; then
        kdiff="$2"
        shift
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
    echo "    options: [--trace] [--help] [--cmd diff-path]"
    echo ""
    echo "Example:"
    echo "    $0 diff.sh do_diff.sh"
    echo ""
    exit
fi
file1="$1"
file2="$2"
input_file1="$file1"
if [ "$OSTYPE" == "cygwin" ]; then
    file1=$(cygpath -w "$file1")
    file2=$(cygpath -w "$file2")
    ## OLD: kdiff="cygstart $kdiff"
fi
## TEMP: applies temporary workaround for symbolic link bug
if [ "$OSTYPE" == "linux" ]; then
    file1=$(realpath "$file1")
    file2=$(realpath "$file2")
fi

# Make sure file2 exists, using relative file1 pattern unless absolute-ish
base1="$(basename "$file1")"
## OLD: if [[ (-d "$file2") && (! "$file1" =~ ^[\/\.].*) && (! -e "$file2/$base1") ]]; then
if [[ (-d "$file2") && (! "$input_file1" =~ ^[\/\.].*) && (! -e "$file2/$base1") ]]; then
    file2="$file2/$input_file1"
fi

# Invoke kdiff
if [ "$DRY_RUN" == "1" ]; then
    echo "$kdiff" "$file1" "$file2"
else
    "$kdiff" "$file1" "$file2" 2>| "$TMP/kdiff-$$.log" &
fi
