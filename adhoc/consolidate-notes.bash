#! /usr/bin/env bash
#
# consolidate-notes.bash: adhoc script for merging notes in chronological order
#
# Notes:
# - TOM-IDIOSYNCRATIC as per tomohara-aliases.bash
# - Addding to user crontab (assuming run in home directory):
#    crontab -e
#
#       # merge notes once a day at 2:30am
#       30 2 * * * ./bin/adhoc/consolidate-notes.bash
#       # format: m h dom mon dow command
# - maldito shellcheck:
#       SC2046: Quote this to prevent word splitting
#       SC2086 (info): Double quote to prevent globbing and word splitting.
#

## DEBUG:
echo "$0 $*"
which python3

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## DEBUG:
## echo "$@"
## set -o xtrace
## DETAILED DEBUG: set -o verbose

# Show usage statement
# TODO: convert into a function that get invoked when $1 is empty or --help
# in $@.
# NOTE: See sync-loop.sh for an example.
#
if [[ ("$1" == "") || ("$1" == "--help") ]]; then
    script=$(basename "$0")
    ## TODO: if [ $script ~= *\ * ]; then script='"'$script'"; fi
    ## TODO: base=$(basename "$0" .bash)
    echo ""
    ## TODO: add option or remove TODO placeholder
    echo "Usage: $0 [--trace] [--help] [--]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 --"
    echo ""
    echo "ALL_TEXT=1 TARGET_DIR=~/notes $script --"
    echo ""
    echo "Notes:"
    echo "- The -- option is to use default options and to avoid usage statement."
    echo "- By default only includes text files with 'notes' in name, along with adhoc filters."
    echo "- Env vars: ALL_TEXT, CRONTAB, SRC_DIR, TRACE, VERBOSE, FIND_COMMAND_OPTIONS, FIND_GLOBAL_OPTIONS."
    echo ""
    exit
fi

# Parse command-line options
# TODO: set getopt-type utility
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
trace=0
while [ "$moreoptions" == "1" ]; do
    if [ "$1" == "--trace" ]; then
	trace=1
    elif [ "${CRONTAB:-0}" == "1" ]; then
        # TEMP: ignore options if invoked via crontab (requires env option)
        echo "Warning: ignoring options ($*)"
	break
    elif [[ ("$1" == "--") || ("$1" == "-") ]]; then
	break
    else
	echo "ERROR: Unknown option: $1";
	exit
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# Enable Bash aliases, etc.
## maldito shellcheck: [SC1090: Can't follow non-constant source]
# shellcheck disable=SC1090
{
    shopt -s expand_aliases
    ## DEBUG: echo "1. $@"
    source ~/bin/tomohara-aliases.bash
    ## DEBUG: echo "2. $@"
    source ~/bin/tomohara-proper-aliases.bash
    ## DEBUG: echo "3. $@"
    source ~/bin/tomohara-settings.bash
}

# Enable tracing
# note: done after alias files sourced to avoid exxtraenous tracing
# TODO2: make note of TRACE and other env. var usage
if [[ ("$trace" == "1") || ("${TRACE:-0}" == "1") ]]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" == "1" ]; then
    set -o verbose
fi

# Get settings from environment
# TODO: expand env. options
base="_master-note-info";
new_base="_new-$base"
## TODO: cd ~/notes-archive
cd "${TARGET_DIR:-.}"
## TEMP: ensure full path used (TODO: only if SRC_DIR equals TARGET_DIR)
cd-realdir
set-xterm-title "merge-notes [$PWD]"

# Rename temporary files (in case of aborted run)
temp_files="$(ls "$new_base.files.list" "$new_base.files.log" "$new_base.list" "$new_base.list.log" 2> /dev/null)"
if [ "" != "$temp_files" ]; then
    echo "Warning: temp files from previous run: $temp_files"
    rename-with-file-date "$new_base.files.list" "$new_base.files.log" "$new_base.list" "$new_base.list.log"
fi

# Prepare list of notes files, excluding backup and temp directories (i.e., files with paths like */backup/* or */temp/*)
# Inclusion pattern:
# - *notes*{txt,list,log}
# - *adhoc*[0-9][0-9]*{txt,list,log}
# Exclusion pattern:
# - backup|old|temp
# - _*adhoc*.log
# note: uses 'wider net' for adhoc notes: requires 'notes' not 'note' to avoid incorporating existing consolidationms (e.g., _master-note-info.list)
# TODO: -o -iname '*.txt' 
# TODO: make '*.txt' optional; check effect on typo in merge_notes arg parsing
# TODO2: use two-part filtering (e.g., first find and then grep)
# TODO1: filter inaccesible files, such as emacs lock files
#     .#_toms-mac-adhoc-notes-jan23.txt -> tohara@tohara-mac.lan.50018
find_command_options="${FIND_COMMAND_OPTIONS:-}"
find_global_options="${FIND_GLOBAL_OPTIONS:-}"
# shellcheck disable=SC2086
if [ "${ALL_TEXT:-0}" == "1" ]; then
    # TODO: rework so that pattern-type options specified individially (e.g., LOG_FILES, ADHOC_NOTES, etc)
    find $find_command_options "${SRC_DIR:-.}" $find_global_options \(  -iname '*.txt' -o -iname '*.text' \) 2> "$new_base.files.log" | $EGREP -iv '/(backup|old|temp)/' | perl -pe 's/ /\\ /g;' > "$new_base.files.list";
else
    # Note: Filters log files starting with _ unless adhoc in the name (e.g., /home/tohara/config/_consolidate-experiment-notes-05apr23.log).
    # This uses the perl-style zero-width negative lookahead regex.
    find $find_command_options "${SRC_DIR:-.}" $find_global_options \( -iname '*adhoc*[0-9][0-9]*.txt' -o -iname '*adhoc*[0-9][0-9]*.list' -o -iname '*adhoc*[0-9][0-9]*.log' -o -iname '*-notes*.txt' -o -iname '*-notes*.list' -o -iname '*-notes*.log' \) 2> "$new_base.files.log" | $EGREP -iv '/(backup|old|temp)/' | $EGREP -iv '/_[^\/]+(?!adhoc)[^\/]+.log' | perl -pe 's/ /\\ /g;' > "$new_base.files.list";
fi
## TODO: if [ -z "$new_base.files.list" ]; then
if [ "$(wc -l < "$new_base.files.list")" == "0" ]; then
    echo "Error: problem finding note files to merge" 1>&2
    exit
fi
check-errors-excerpt "$new_base.files.log"

# Perform the note entry merging
# TODO: check stdin support in main.py
# shellcheck disable=SC2086
DEBUG_LEVEL=4 xargs $PYTHON -m mezcla.merge_notes --ignore-dividers --output-dividers --show-file-info < "$new_base.files.list" > "$new_base.list" 2> "$new_base.list.log";
check-errors-excerpt "$new_base.list.log";

# Set read-only
chmod ugo-w $new_base*;

# Rename existing master note files
# TODO: exclude cases already with timestamps
rename-with-file-date "$base.files.list" "$base.files.log" "$base.list" "$base.list.log" 
## TODO: rename-with-file-date "$base"*[a-z]

# Rename new file to use target name
# TODO1: fix following
#    "_master-note-info.list.06apr23.log" already exists! not mv'ing "_new-_master-note-info.list.06apr23.log" "_master-note-info.list.06apr23.log"
# shellcheck disable=SC2046
rename-files "$new_base" "$base" $(ls "$new_base"* | $EGREP -v "\d{2}\w+\d{2}")
