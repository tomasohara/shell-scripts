#! /usr/bin/env bash
#
# consolidate-notes.bash: adhoc script for merging notes in chronological order
#
# Notee:
# - TOM-IDIOSYNCRATIC as per tomohara-aliases.bash
# - Addding to user crontab (assuming run in home directory):
#    crontab -e
#
#       # merge notes once a day at 2:30am
#       30 2 * * * ./bin/adhoc/consolidate-notes.bash
#       # format: m h dom mon dow command
#

echo "0. $@"

# Enable Bash aliases, etc.
## maldito shellcheck: [SC1090: Can't follow non-constant source]
# shellcheck disable=SC1090
{
    shopt -s expand_aliases
echo "1. $@"
    source ~/bin/tomohara-aliases.bash
echo "2. $@"
    source ~/bin/tomohara-proper-aliases.bash
echo "3. $@"
    source ~/bin/tomohara-settings.bash
}

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
echo "$@"
## set -o xtrace
## DEBUG: set -o verbose

# Show usage statement
# TODO: convert into a function that get invoked when $1 is empty or --help
# in $@.
# NOTE: See sync-loop.sh for an example.
#
if [[ ("$1" = "") || ("$1" = "--help") ]]; then
    script=$(basename "$0")
    ## TODO: if [ $script ~= *\ * ]; then script='"'$script'"; fi
    ## TODO: base=$(basename "$0" .bash)
    echo ""
    ## TODO: add option or remove TODO placeholder
    echo "Usage: $0 [--TODO] [--trace] [--help] [--]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 --"
    echo ""
    echo "ALL_TEXT=2 TARGET_DIR=~/notes $script --"
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
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    # TODO : add real options
    if [ "$1" = "--trace" ]; then
	set -o xtrace
    elif [ "$1" = "--fubar" ]; then
	echo "fubar"
    elif [[ ("$1" = "--") || ("$1" = "-") ]]; then
	break
    else
	echo "ERROR: Unknown option: $1";
	exit
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# Get settings from environment
# TODO: expand env. options
base="_master-note-info";
new_base="_new-$base"
## TODO: cd ~/notes-archive
cd "${TARGET_DIR:-.}"
set-xterm-title "merge-notes [$PWD]"

## OLD:
## init-conda-arm64
## conda-activate-env nlp-py-3-9
## ## alt: support for maldito mac-m1
## ## init-conda-x86_64; conda activate test-py-3-6-x86_64
## ## TEMP
## prepend-path /opt/homebrew/Caskroom/miniforge/base/envs/nlp-py-3-9/bin

# Prepare list of notes files, excluding backup and temp directories (i.e., files with paths like */backup/* or */temp/*)
# note: uses 'wider net' for adhoc notes; uses *notes* to avoid incorporating existing consolidationms (e.g., _master-note-info.list)
# TODO: -o -iname '*.txt' 
# TODO: make '*.txt' optional; check effect on typo in merge_notes arg parsing
if [ "${ALL_TEXT:-0}" = "1" ]; then
    # TODO: rework so that pattern-type options specified individially (e.g., LOG_FILES, ADHOC_NOTES, etc)
    find "${SRC_DIR:-.}" \(  -iname '*.txt' -o -iname '*.text' \) 2> "$new_base.files.log" | egrep -iv '/(backup|temp)/' | perl -pe 's/ /\\ /g;' > "$new_base.files.list";
else
    find "${SRC_DIR:-.}" \( -iname '*adhoc*[0-9][0-9]*.txt*' -o -iname '*adhoc*[0-9][0-9]*.log*' -o -iname '*-notes*.txt' -o -iname '*-notes*.list' -o -iname '*-notes*.log' \) 2> "$new_base.files.log" | egrep -iv '/(backup|temp)/' | perl -pe 's/ /\\ /g;' > "$new_base.files.list";
fi
check-errors-excerpt "$new_base.files.log"

# Perform the note entry merging
# TODO: check stdin support in main.py
# maldito shellcheck: SC2086 (info): Double quote to prevent globbing and word splitting.
# shellcheck disable=SC2086
DEBUG_LEVEL=4 xargs $PYTHON -m mezcla.merge_notes --ignore-dividers --output-dividers --show-file-info < "$new_base.files.list" > "$new_base.list" 2> "$new_base.list.$(TODAY).log";
check-errors-excerpt "$new_base.list.$(TODAY).log";

# Set read-only
chmod ugo-w $new_base*;

# Rename existing master note files
# TODO: exclude cases already with timestamps
## OLD: rename-with-file-date "$base.files.list" "$base.list" "$base.log" "$base.files.log"
rename-with-file-date "$base.files.list" "$base.list" "$base.log" "$base.files.log" 2>&1 | egrep -v "\d{2}\w+\d{2}.*already exists"

# Rename new file to use target name
rename-files "$new_base" "$base" "$new_base"*
