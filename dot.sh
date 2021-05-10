#! /bin/csh -f
#
# dot.sh: Sets the environment for dot and then invokes it, defaulting to
# postscript output
#
# dot is AT&T's DAG graphing utility (part of graphviz)
#
# TODO: combine with dotty.sh
#
# examples: 
#
#    dot.sh -Tps my.dot -o my.ps
#
#    dot.sh -Gpage="8.5,11" -Grotate=90 -Gratio=auto dj42_1638.dot
#

## set echo = 1

if ($#OSTYPE == 0) setenv OSTYPE=Win32
if (("$OSTYPE" == "posix") && ($#WINDIR != 0)) setenv OSTYPE CygWin
if (("$OSTYPE" == "Win32") || ("$OSTYPE" == "CygWin")) then
   set windrive=`echo $WINDIR | perl -pe "s/^(\w):.*/\L\1/;"`
   ## setenv GRAPHVIZ_HOME "/cygdrive/$windrive/Program Files/ATT/Graphviz/bin"
   setenv GRAPHVIZ_HOME "/cygdrive/$windrive/Program-Misc/Graphviz"
   ## setenv PATH "${PATH}:${GRAPHVIZ_HOME}/bin"
   setenv PATH "${GRAPHVIZ_HOME}/bin:${PATH}"
   ## echo "path: $PATH"
   setenv DOTFONTPATH "${windrive}:\\windows\\fonts"
else
   if ($#GRAPHLING_HOME == 0) setenv GRAPHLING_HOME /home/graphling
   setenv GRAPHVIZ_HOME "${GRAPHLING_HOME}/TOOLS/GRAPHVIZ/"
   setenv LEFTYPATH "${GRAPHVIZ_HOME}/lib/lefty/"
   setenv PATH "${PATH}:${GRAPHVIZ_HOME}/$OSTYPE/bin"
endif

if ($OSTYPE == "sunos4") then
    echo "WARNING: the version of dot for SunOS4 is broken: run under Solaris"
endif

set args = ""
set view = 0
set postscript = 1
set extension = ".ps"
set file = ""
set to_file_needed = 1
set other_type_args = ""
while ("$1" != "") 
    if ("$1" == "--view") then
	set file = $2
	set view = 1
	shift
    else if (("$1" == "-T") && ("$2" != "ps")) then
        set postscript = 0
	set extension = ".$2"
	set other_type_args = "-T$2"
	shift
    else if ("$1" == "-T") then
        set postscript = 0
	set other_type_args = "-T$2"
	shift
    else if ("$1" =~ -T*) then
        set postscript = 0
	set other_type_args = "$1"
	set extension = `echo "$1" | perl -pe 's/^\-T/\./;'`
    else if ("$1" == "-o") then
        set to_file_needed = 0
        set args = "$args $1 $2"
	shift
    else if ("$1" =~ -*) then
        set args = "$args $1"
    else if ($file == "") then
        set file = $1
    endif
    shift
end

if ($file == "") then
    echo ""
    echo "usage: `basename $0` [--view] [dot arguments] file"
    echo ""
    echo "examples:"
    echo ""
    echo "dot.sh -Tps my.dot -o my.ps"
    echo ""
    echo "dot.sh -Gpage='8.5,11' -Grotate=90 -Gratio=auto dj42_1638.dot"
    echo ""
    echo "NOTES:"
    echo "- Currently only suported under solaris (e.g., guinness host)"
    echo "- Enclose arguments to dot w/ embedded spaces in double quotes"
    echo "- Output types: ps hpgl pcl mif gif ismap dot canon plain"
    echo ""
    exit
endif

if ($view == 1) then
    # TODO: revise wrt output type and extension
    echo "issuing: dot -Tps $args $file $* -o /tmp/$base.ps"
    dot -Tps $args $file $* -o /tmp/$base.ps
    ghostview /tmp/$base.ps &
else
    set output = "-o `basename $file .dot`$extension"
    if ($to_file_needed == 0) set output = ""
    set type_args = "-Tps"
    if ($postscript == 0) set type_args = "$other_type_args"

    echo "issuing: dot $type_args $output $args $file"
    dot $type_args $output $args $file
endif
