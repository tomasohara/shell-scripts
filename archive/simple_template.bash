#! /usr/bin/env bash
#
# TODO: name.sh: brief explanation
#
#    TODO: details
#
# Note:
# - See bash-cheatsheet.md for commonly used bash snippets.
# - This was inspired by TODO.
#
# TODO:
# - Stuff to be addressed ... TODO.
#

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

# Show usage statement
# TODO: convert into a function that get invoked when $1 is empty or --help
# in $@.
# NOTE: See sync-loop.sh for an example.
#
if [[ "$1" == "" ]]; then
    script=$(basename "$0")
    ## TODO: remove following which is only meant for when ./template.bash run
    if [[ "$script" == "template.bash" ]]; then echo "Warning: not intended for standalone usage"; fi;
    ## TODO: if [[ $script ~= *\ * ]]; then script='"'$script'"; fi
    ## TODO: base=$(basename "$0" .bash)
    echo ""
    ## TODO: add option or remove TODO placeholder
    echo "Usage: $0 [--TODO] [--trace] [--help] [--| -]"
    echo ""
    echo "Examples:"
    echo ""
    ## TODO: example 1
    echo "$0 example 1"
    echo ""
    ## TODO: example 2
    echo "$script example 2"
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
while [[ "$moreoptions" == "1" ]]; do
    # TODO: add real options
    if [[ "$1" == "--trace" ]]; then
        set -o xtrace
    elif [[ "$1" == "--TODO-fubar" ]]; then
        ## TODO: implement
        echo "TODO-fubar"
    elif [[ ("$1" == "--") || ("$1" == "-") ]]; then
        shift
        break
    else
        echo "Error: Unknown option: $1";
        exit
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
# TODO: add positional arg assignment (delete if not planned)
## todo_arg1="$1"

# TODO: Do whatever
