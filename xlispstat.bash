#!/bin/bash
#
# xlispstat.sh: invokes the right version of xlispstat for the platform
# (Linux or Sun Solaris), using the required resource/working storage 
# file (xlisp.wks)
#
# NOTES:
# - xlispstat arguments:
#     t<file>   transcript
#     b         batch mode
#     v         verbose
#     w<file>   resource file
#     p<path>   default path
#     <file>    lisp code to load
# - script options:
#    --interactive	same as -b
#    --non-X		for use in non-Windows settings (e.g., remote telnet)
# - based on xlispstat.sh with conversion by ChatGPT
#
# The --non-X option is to support remote Unix sessions (i.e., from Windows)
# This leads to the following warning
#     /home/graphling/TOOLS/XLISPSTAT/xlisp_linux: can't connect to X server
# Without the option, the script will fail with the following type of error:
#     X connection to dago:10.0 broken (explicit kill or server shutdown).
#
# Graphics commands (see http://citeseer.ist.psu.edu/327507.html):
#   (plot-points var1 var2)
#   (plot-lines var1 var2)
#   (histogram var1)
#
# TODO: Make sure the optional modules (eg, anova2.lsp) are loaded before
#       the user modules.
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## DEBUG: set -o verbose
#
# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Specify based directory
if [[ -z "$XLISPLIB" ]]; then
    ## OLD export XLISPLIB="c:/Program-Misc/lisp/xlispstat-3-52-20"
    export XLISPLIB="/home/tomohara/lib/xlispstat"
fi

dir=$(dirname "$0")

# Show usage
if [[ -z "$1" ]]; then
    echo ""
    # silly shellcheck: SC2016 (info): Expressions don't expand in single quotes
    # shellcheck disable=SC2016
    echo "usage: $(basename '$0') [--interactive] [--non-X] xlisp-file"
    echo ""
    echo "example:"
    echo "$0 --interactive --non-X"
    echo ""
    exit 1
fi

# Separate xlispstat arguments from files to load
args=""
while [[ "$1" =~ ^-.* ]]; do
    case "$1" in
        --inter*)
            args="$args -b"
            ;;
        --non-X)
            ## echo "Unsetting DISPLAY"
            # NOTE: Doesn't seems to work under CygWin
            if [[ -n "$DISPLAY" ]]; then
                ## if [ "$DISPLAY" == "localhost:0.0" ]; then unsetenv DISPLAY; fi
                unset DISPLAY
            fi
            ;;
        *)
            args="$args $1"
            ;;
    esac
    shift
done
user_files=("$@")

# Determine the base filename
XLISP="xlisp"
if [[ "${OSTYPE:-""}" == "linux" ]]; then
    XLISP="xlisp_linux"
fi

# Determine the file for the working storage (saved state of xlisp)
if [[ -f "$dir/${XLISP}.wks" ]]; then 
    WKS="$dir/${XLISP}.wks"
else 
    WKS="${XLISPLIB}/${XLISP}.wks"
fi

# Determine the file for the executable
if [[ -f "$dir/$XLISP" ]]; then 
    XLISP_PROG="$dir/$XLISP"
else 
    XLISP_PROG="${XLISPLIB}/$XLISP"
fi

# Determine if optional modules should be loaded
optional_files=""
if [[ "$(printenv USE_XLISP_EXTS)" == "1" ]]; then
    optional_files="${optional_files} ${XLISPLIB}/Contributions/regress.lsp ${XLISPLIB}/Contributions/anova2.lsp"
fi

# Finally, run xlispstat
WKS_OPTION="-w${WKS}"
if [ "${SKIP_WKS:-0}" == "1" ]; then WKS_OPTION=""; fi
echo "Issuing: exec ${XLISP_PROG} ${WKS_OPTION} $args ${optional_files} ${user_files[*]}"
# note: SC2086 (info): Double quote to prevent globbing and word splitting.
# shellcheck disable=SC2086
exec ${XLISP_PROG} ${WKS_OPTION} $args ${optional_files} "${user_files[@]}"
