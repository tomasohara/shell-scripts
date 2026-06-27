#! /usr/bin/env bash
#
# TODO: name.sh: brief explanation
#
# TODO: details (e.g., a paragraph or two)
#
# Note:
# - See bash-cheatsheet.md for commonly used bash snippets.
# - This was inspired by TODO.
#
# TODO:
# - Review Bash "Pro Tips" in bash-cheatsheet.md.
# - Customize this script by addressing TODO's (and then remove them).
# - Mention stuff to be addressed ... TODO.
#
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
if [[ "${STRICT:-0}" == "1" ]]; then
    set -euo pipefail
fi

# Display command-line usage
function usage() {
    local script
    script=$(basename "$0")
    echo ""
    ## TODO: update options list to match actual options
    echo "Usage: $script [--TODO-option] [--verbose] [--trace] [--help] [-- | -]"
    echo ""
    echo "Examples:"
    echo ""
    ## TODO: example 1
    echo "$script example-arg-1"
    echo ""
    ## TODO: example 2
    echo "$script --TODO-option example-arg-2"
    echo ""
    echo "Notes:"
    echo "- The -- option uses defaults and avoids the usage statement."
    echo "- Use DEBUG_SCRIPT=1 to show getopt processing."
    ## TODO: add more notes
    echo ""
}

# Initialize options
# TODO: add/remove variables to match actual options below
show_usage=0
trace=0
verbose=0
## TODO: add script-specific option variables (examples):
## fubar=0
## level=0
DEBUG_SCRIPT=$([ "${DEBUG_SCRIPT:-0}" -eq 1 ] && echo true || echo false)
orig_argc=$#

# Parse options with getopt
# Note:
# - getopt unravels combined short options (e.g., "-tv" -> "-t -v")
# - options taking a value argument have a colon appended (e.g., "level:").
# - see examples/chatgpt-get-long-options-parsing.bash for more background.
# TODO: update -o and --long specs to match your options
TEMP=$(getopt -o htv --long help,trace,verbose -n "$0" -- "$@")
status=$?
if [ $status != 0 ]; then
    echo "Error: getopt failed (status=$status); terminating." >&2
    exit 1
fi
$DEBUG_SCRIPT && echo "TEMP=$TEMP"
# Reassign $1, $2, etc. to the normalized getopt output.
# Note: quotes around "$TEMP" are essential.
eval set -- "$TEMP"

# Process each option
while true; do
    $DEBUG_SCRIPT && echo "\$1=$1"
    case "$1" in
        -h|--help)
            show_usage=1
            shift
            ;;
        ## TODO: add script-specific options (see commented examples below)
        ## -f|--fubar)
        ##     fubar=1
        ##     shift
        ##     ;;
        ## -l|--level)
        ##     level="$2"
        ##     shift 2
        ##     ;;
        -t|--trace)
            trace=1
            shift
            ;;
        -v|--verbose)
            verbose=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error: unexpected option: $1" >&2
            exit 1
            ;;
    esac
done

# Apply trace and verbose now that they've been parsed
# note: This is the preferred way to trace the script proper
if [ "$trace" == "1" ]; then
    set -o xtrace
fi
if [ "$verbose" == "1" ]; then
    set -o verbose
fi

# Show usage if --help or if no arguments were given at all (orig_argc=0).
# Note: passing -- explicitly skips the no-arg check (orig_argc > 0).
# TODO: replace orig_argc check with [ "$#" -eq 0 ] if positional args are required
if [ "$show_usage" == "1" ] || [ "$orig_argc" -eq 0 ]; then
    ## TODO: remove the following line (only relevant when running template.bash directly)
    if [[ "$(basename "$0")" == "template.bash" ]]; then echo "Warning: not intended for standalone usage"; fi
    usage
    exit
fi

# TODO: assign positional arguments (delete if not planned)
## arg1="$1"
## arg2="${2:-}"

# TODO: do whatever
   
