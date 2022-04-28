#! /bin/bash
# 
# Invokes Emacs with current directory unless files specified on command
# line and using ~/.emacs.tpo instead of ~/.emacs (for when using shared
# hosts). If the X-Windows DISPLAY environment is not set, then
# the console version of Emacs is forced (via --no-windows).
#
# Notes:
# - Background support is placed here rather than in Bash aliases or
# functions, so that the Emacs processes don't show up via Bash jobs
# command (as it tends to clutter the display).
# - Basis for em alias under Linux.
# - See win32-emacs.sh for similar script for use under Cygwin.
#
#-------------------------------------------------------------------------------
# Note: Based on following alias/functions definition (see tohara-aliases.bash)
#
# emacs_options="--geometry 80x50"
# if [ -e "~/.emacs.tpo" ]; then
#     alias emacs-tpo='emacs -l ~/.emacs.tpo'
#     if [ "$DISPLAY" = "" ]; then 
# 	alias emacs-tpo='emacs -l ~/.emacs.tpo --no-windows $emacs_options'
# 	function em () { if [ "$1" = "" ]; then emacs-tpo .; else emacs-tpo "$@"; fi; }
#     else
# 	function em () { if [ "$1" = "" ]; then emacs-tpo .; else emacs-tpo "$@"; fi & }
#     fi
# else
#     function em () { if [ "$1" = "" ]; then emacs $emacs_options .; else emacs $emacs_options "$@"; fi & }
#     alias emacs-tpo=em
# fi
#

# TODO: Show usage statement
#
if [ "$1" = "--help" ]; then
    script=$(basename "$0")
    echo ""
    echo "usage: $script [--trace] [--options token-or-string] [--foreground] [--quick] [--]"
    echo ""
    echo "ex: $0 -- --geometry 80x50"
    echo ""
    echo "Note: put emacs arguments after --"
    echo ""
    exit
fi

# Setup Emacs options (50 rows, 80 columns, and use background process)
## OLD: emacs_options="--geometry 80x50"
emacs_options=""
in_background="1"

# Parse command-line options
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
quick=0
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--foreground" ]; then
	in_background="0"
    elif [[ ("$1" = "-q") || ("$1" = "--quick") ]]; then
	emacs_options="$emacs_options -q";
	quick=1
    elif [ "$1" = "--options" ]; then
	emacs_options="$emacs_options $2";
	shift;
    elif [ "$1" = "--" ]; then
	shift;
	break;
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
# note: remainder of "$@" used below

# Force console model if DISPLAY environment not set
if [ "$DISPLAY" = "" ]; then 
    emacs_options="$emacs_options --no-windows"
    in_background="0"
fi

# Use ~/.emacs.tpo (in place of ~/.emacs) if available
if [[ ($quick = "0") && (-e "$HOME/.emacs.tpo") ]]; then
     emacs_options="$emacs_options -l $HOME/.emacs.tpo"
fi

# Invoke emacs
# note: disables warning "Double quote to prevent globbing"
# shellcheck disable=SC2086
if [ "$in_background" = "1" ]; then
    # note: eval not used with variable for "&" in case spaces in filenames
    # TODO: rework so that no-op option added if empty (to avoid SC2086 disabled)
    #   ex: emacs "${emacs_options:- --eval 1}" "$@" &
    emacs $emacs_options "$@" &
else
    emacs $emacs_options "$@"
fi
