#! /usr/bin/env bash
#
# char-diff.bash: produce character-based diff
# See https://stackoverflow.com/questions/1721738/using-diff-or-anything-else-to-get-character-level-diff-between-text-files
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## DEBUG: set -o verbose

# Parse command-line options
# TODO: set getopt-type utility
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    # TODO : add real options
    if [ "$1" = "--trace" ]; then
	set -o xtrace
    elif [ "$1" = "--TODO-fubar" ]; then
	## TODO: implement
	echo "TODO-fubar"
    elif [[ ("$1" = "--") || ("$1" = "-") ]]; then
	break
    else
	echo "ERROR: Unknown option: $1";
	exit
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
file1="$1"
file2="$2"

# Show usage statement
# TODO: convert into a function that get invoked when $1 is empty or --help
# in $@.
# NOTE: See sync-loop.sh for an example.
#
if [ "$file2" = "" ]; then
    script=$(basename "$0")
    ## TODO: if [ $script ~= *\ * ]; then script='"'$script'"; fi
    ## TODO: base=$(basename "$0" .bash)
    echo ""
    ## TODO: add option or remove TODO placeholder
    echo "Usage: $0 [--TODO] [--trace] [--help] [--]"
    echo ""
    echo "Examples:"
    echo ""
    ## TODO: example 1
    echo "$0 .bashrc backup/.bashrc"
    echo ""
    ## TODO: example 2
    echo "$script debug.py ~/temp/debug.py"
    echo ""
    echo "Notes:"
    echo "- The -- option is to use default options and to avoid usage statement."
    ## TODO: add more notes
    ## echo ""
    echo ""
    exit
fi

# Invoke python difflib
python - <<END_SNIPPET
import difflib, sys;
print("".join(difflib.ndiff(open("$file1").readlines(),
                            open("$file2").readlines())))
END_SNIPPET
