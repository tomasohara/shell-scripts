#! /bin/bash
#
# sindex.sh: simple wrapper around RWare sindex command
#
# Example:
#    sindex.sh TestingLib
#    =>
#    sindex -new -library TestingLib -path_num 1
#
# TODO:
# - Add support for indexing other directories:
#      sindex -new -library TestingLib -file 'c:\temp\langid-texts\*.html' -recursive
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## set -o xtrace
## set -o verbose

# Show usage statement
#
if [ "$1" = "" ]; then
    echo ""
    echo "usage: `basename $0` [--utf8] [sindex-options] library"
    echo ""
    echo "ex: `basename $0` --utf8 TestingLib"
    echo ""
    echo "note: library always indexed from scratch"
    exit
fi

# Parse command-line options
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--utf8" ]; then
	# Print BOM marker for UTF8 output (U+FEFF or 0xEF 0xBB 0xBF)
	echo $'\xEF\xBB\xBF'
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# Index the library
sindex -new -log_level 4 -library $* -path_num 1
