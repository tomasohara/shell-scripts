#! /bin/bash
#
# win32-emacs.sh: simple wrapper around GNU emacs under CygWin running it in background
#
# NOTE:
# - This is intended for the Win32 version of Emacs not the CygWin version.
# - Intended for use with my 'em' alias so that background spec. not needed.
# Old:
#   function em () { if [ "$1" = "" ]; then emacs- .; else emacs- "$@"; fi & }
# New:
#   alias em='emacs.sh'
#

# Uncomment the line(s) below for tracing (verbose shows command before and after, xtrace just shows it after):
#  
## set -o xtrace
## set -o verbose

# Parse arguments: [--devel]
# TODO: check for generic emacs-[0-9]*-[0-9]* pattern 
if [ "$EMACSDIR" == "" ]; then EMACSDIR="/$WINDRIVE/Program-Misc/GNU/emacs"; fi
if [ ! -d "$EMACSDIR" ]; then EMACSDIR="/$WINDRIVE/Program-Misc/GNU/emacs-25-1-2"; fi
if [ ! -d "$EMACSDIR" ]; then EMACSDIR="/$WINDRIVE/Program-Misc/GNU/old/emacs-24.3"; fi
if [ ! -d "$EMACSDIR" ]; then EMACSDIR="/$WINDRIVE/Program-Misc/GNU/old/emacs-23.3"; fi
if [ ! -d "$EMACSDIR" ]; then EMACSDIR="/$WINDRIVE/Program-Misc/GNU/old/emacs-23.2"; fi
if [ ! -d "$EMACSDIR" ]; then EMACSDIR="/$WINDRIVE/Program-Misc/GNU/old/emacs-22.3"; fi
if [ ! -d "$EMACSDIR" ]; then EMACSDIR="/$WINDRIVE/Program-Misc/GNU/old/emacs-21.3"; fi
if [ ! -d "$EMACSDIR" ]; then EMACSDIR="/$WINDRIVE/Program-Misc/GNU/old/emacs-21.1"; fi
if [ "$1" = "--devel" ]; then EMACSDIR="/$WINDRIVE/Program-Misc/GNU/old/emacs-devel"; shift 1; fi

# If no files specified, default to "." for current directory dired listing.
if [ "$1" = "" ]; then set .; fi

# Edit the files, running in the background
# NOTE: assumes /c mapped to /cygdrive/c, etc.; also WINDRIVE gives letter for Windows drive
"$EMACSDIR/bin/runemacs.exe" "$@" &
