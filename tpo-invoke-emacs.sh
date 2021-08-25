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
    echo ""
    echo "usage: `basename $0` [--trace] [--foreground]"
    echo ""
    echo "ex: `basename $0` --trace"
    echo ""
    exit
fi

# Setup Emacs options (50 rows, 80 columns, and use background process)
emacs_options="--geometry 80x50"
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
    elif [ "$1" = "-q" ]; then
	emacs_options="$emacs_options -q";
	quick=1
    elif [ "$1" = "--" ]; then
	break;
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# Force console model if DISPLAY environment not set
if [ "$DISPLAY" = "" ]; then 
    emacs_options="$emacs_options --no-windows"
    in_background="0"
fi

# Use ~/.emacs.tpo (in place of ~/.emacs) if available
if [[ ($quick = "0") && (-e "~/.emacs.tpo") ]]; then
     emacs_options="$emacs_options -l ~/.emacs.tpo"
fi

# Invoke emacs
if [ "$in_background" = "1" ]; then
    # note: eval not used with variable for "&" in case spaces in filenames
    emacs $emacs_options "$@" &
else
    emacs $emacs_options "$@"
fi
