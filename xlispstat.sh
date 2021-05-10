#!/bin/csh -f
#
# xlispstat.sh: invokes the right version of xlispstat for the platform
# (Linux or Sun Solaris), using the required resource/working storage 
# file (xlisp.wks)
#
# NOTES:
#
# xlispstat arguments:
#     t<file>   transcript
#     b         batch mode
#     v         verbose
#     w<file>   resource file
#     p<path>   default path
#     <file>    lisp code to load
#
# script options
#    --interactive	same as -b
#    --non-X		for use in non-Windows settings (e.g., remote telnet)
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
#------------------------------------------------------------------------
# Uncomment the following for script tracing:
# set echo=1

if ($?XLISPLIB == 0) then
    ## OLD: setenv XLISPLIB /home/graphling/TOOLS/XLISPSTAT
    setenv XLISPLIB c:/Program-Misc/lisp/xlispstat-3-52-20
endif
set dir = `dirname $0`

# Show usage
if ("$1" == "") then
    echo ""
    echo "usage: `basename $0` [--interactive] [--non-X] xlisp-file"
    echo ""
    echo "example:"
    echo "$0 --interactive --non-X"
    echo ""
    exit
endif

# Separate xlispstat arguments from files to load
set args = ""
while ("$1" =~ -*)
    if ("$1" =~ --inter*) then
    	set args = "$args -b"
    else if ("$1" == "--non-X") then
        ## echo "Unsetting DISPLAY"
        # NOTE: Doesn't seems to work under CygWin
        if ( $?DISPLAY ) then
	    ## if ( "$DISPLAY" == "localhost:0.0" ) unsetenv DISPLAY 
	    unsetenv DISPLAY 
	endif
    else
	set args = "$args $1"
    endif
    shift
end
set user_files=$*

# Determine the base filename
#
set XLISP=xlisp
if (`printenv OSTYPE` == "linux") then
    set XLISP=xlisp_linux
endif

# Determine the file for the working storage (saved state of xlisp)
#
if (-f $dir/${XLISP}.wks) then 
    set WKS="$dir/${XLISP}.wks"
else 
    set WKS="${XLISPLIB}/${XLISP}.wks"
endif

# Determine the file for the executable
#
if (-f $dir/$XLISP) then 
    set XLISP_PROG=$dir/$XLISP
else 
    set XLISP_PROG="${XLISPLIB}/$XLISP"
endif

# Determine if optional modules should be loaded
#
set optional_files = ""
if (`printenv USE_XLISP_EXTS` == 1) then
    set optional_files = "${optional_files} ${XLISPLIB}/Contributions/regress.lsp ${XLISPLIB}/Contributions/anova2.lsp"
endif

# Finally, run xlispstat
#
echo "Issuing: exec ${XLISP_PROG} -w${WKS} $args ${optional_files} ${user_files}"
exec ${XLISP_PROG} -w${WKS} $args ${optional_files} ${user_files}
