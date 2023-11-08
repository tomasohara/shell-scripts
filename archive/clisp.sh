#! /bin/bash
#
# clisp.sh: script for invoking CLISP under Unix (e.g., CygWin version under Win32)
#
# Uncomment the line(s) below for tracing (verbose shows command before and after, xtrace just shows it after):
#  
# CLISP options (see http://clisp.cons.org/clisp.html):
#    -B dir                installation dir
#    -M file               specify memory image
#    -m size               specify memory size (now just applies to stack)
#    -q                    quiet initialiation mode
#    -E[domain] encoding   set character set for terminal, file I/O, etc.
#
# NOTES:
# - ISO-8859-1 is the standard encoding for the Latin alphabet as used in
#   various Romance languages.
# - See CLISP Implementatio Notes for the various encodings supported:
#   http://clisp.cons.org/impnotes.html.
#........................................................................
# CLISP options:
#
#   $ /usr/bin/clisp --help
#   GNU CLISP (http://clisp.cons.org/) is an ANSI Common Lisp.
#   Usage:  /usr/lib/clisp/base/lisp.run [options] [lispfile [argument ...]]
#    When `lispfile' is given, it is loaded and `*ARGS*' is set
#    to the list of argument strings. Otherwise, an interactive
#    read-eval-print loop is entered.
#   Informative output:
#    -h, --help    - print this help and exit
#    --version     - print the version information
#    --license     - print the licensing information
#   Memory image selection:
#    -B lisplibdir - set the installation directory
#    -K linkingset - use this executable and memory image
#    -M memfile    - use this memory image
#    -m size       - memory size (size = xxxxxxxB or xxxxKB or xMB)
#   Internationalization:
#    -L language   - set user language
#    -N nlsdir     - NLS catalog directory
#    -Edomain encoding - set encoding
#   Interoperability:
#    -q, --quiet, --silent - do not print the banner
#    -w            - wait for keypress after program termination
#    -I            - be ILISP-friendly
#   Startup actions:
#    -ansi         - more ANSI CL compliance
#    -traditional  - traditional (undoes -ansi)
#    -p package    - start in the package
#    -C            - set *LOAD-COMPILING* to T
#    -v, --verbose - set *LOAD-PRINT* and *COMPILE-PRINT* to T
#    -norc         - do not load the user ~/.clisprc file
#    -i file       - load initfile (can be repeated)
#   Actions:
#    -c [-l] lispfile [-o outputfile] - compile LISPFILE
#    -x expressions - execute the expressions, then exit
#    lispfile [argument ...] - load lispfile, then exit
#   These actions put CLISP into a batch mode, which is overridden by
#    -interactive-debug - allow interaction for failed ASSERT and friends
#    -repl              - enter the interactive read-eval-print loop when done
#   Default action is an interactive read-eval-print loop.
#
#------------------------------------------------------------------------
# TODO:
# - allow for overriding default options
#

# set -o verbose
# set -o xtrace

# Show usgae if insufficient arguments given
if [ "$1" = "" ]; then
    script_name=`basename $0`
    echo ""
    echo "usage: `basename $0` [--image file | -] [--nodefaults] [-- clisp-options]"
    echo ""
    echo "clisp-options: [-h] [-q] [-v] [-norc] [-i file] [-x expressions]"
    echo "               [-C] [-c file] [-B dir] [-M file] [-m size] [-Edom enc]"
    echo ""
    echo "examples:"
    echo ""
    echo "$0 --"
    echo ""
    echo "$script_name --image lispinit.mem"
    echo ""
    echo "cd /home/shared/bin/Full_Analyzer"
    echo "nice -19 $script_name --image ./lispinit.mem -- -x '(analyze-text \"sentences.txt\")' >| sentences.log 2>&1"
    echo ""
    echo "$script_name --image /home/shared/bin/Full_Analyzer/lispinit.mem"
    echo ""
    echo "notes:"
    echo "- Default options: -q -E ISO-8859-1."
    echo "- Use -- by itself to run clisp with default arguments."
    echo "- Use - option to run with lispinit.mem in current directory."
    echo ""
    exit
fi

# Parse command-line arguments
# NOTE: '-' is ignored: it is used to by-pass usage
default_options="-q -E ISO-8859-1"
image_file=""
image_option=""
clisp_dir_option=""
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--image" ]; then
	image_file="$2"
	shift 1;
    elif [ "$1" = "-" ]; then
	image_file="lispinit.mem"
    elif [ "$1" = "--no-image" ]; then
	image_file=""
    elif [ "$1" = "--nodefaults" ]; then
	default_options=""
    elif [ "$1" = "--" ]; then
	moreoptions=0
    else
	echo "unknown option: $1";
    fi
    shift 1;
    if [ "$moreoptions" = "1" ]; then moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac; fi
done

# Veirfy that the image file exists
if [ "$image_file" != "" ]; then
    if [ ! -f "$image_file" ]; then
	echo "ERROR: unable to find image file: '$image_file'"
	exit
    fi
    image_option="-M $image_file"
fi

# Under Windows, set CLISP to CLISPDIR's full version of lisp.exe (if found).
# TODO: Use '-K full' command-line option to streamline invocation.
#
if [[ ("$CLISP" = "") && ("$CLISPDIR" != "") && ("$WINDIR" != "") ]]; then
    CLISP="$CLISPDIR/full/lisp.exe"; 
    clisp_dir_option="-B $CLISPDIR/full"
    if [ "$image_file" = "" ]; then
	image_option="-M $CLISPDIR/full/lispinit.mem";
    fi
fi

# See whether the old version of clisp should be used
# NOTE: This checks for the file USE_OLD_CLISP in the current directory
if [[ ("$CLISP" == "") && (-e "USE_OLD_CLISP") ]]; then 
    clisp_dir=/home/shared/tools/clisp-2.33
    CLISP=$clisp_dir/usr/bin/clisp
    clisp_dir_option="-B $clisp_dir/usr/lib/clisp"
elif [ "$CLISP" == "" ]; then
    CLISP=/usr/local/bin/clisp;
fi

# Make sure CLISP exists, otherwise use system default
if [ ! -e "$CLISP" ]; then
    CLISP=clisp
    clisp_dir_option=""
fi

# Run CLISP in quiet startup mode and using latin character set
set -o xtrace
$CLISP $clisp_dir_option $default_options $image_option "$@"
