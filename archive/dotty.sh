#! /bin/csh -f
#
# dotty.sh: sets the environment for dotty and then invokes it
#
# dotty is AT&T's DAG graphing utility (part of graphviz)
#
# NOTE:  usage: dotty [-V] [-lm (sync|async)] [-el (0|1)] <filename>
#

if ($#GRAPHLING_HOME == 0) setenv GRAPHLING_HOME /home/graphling
setenv GRAPHVIZ_HOME ${GRAPHLING_HOME}/TOOLS/GRAPHVIZ/
setenv LEFTYPATH ${GRAPHVIZ_HOME}/lib/lefty/
setenv PATH ${PATH}:${GRAPHVIZ_HOME}/$OSTYPE/bin
if ($OSTYPE == "sunos4") then
    echo "WARNING: the version of dotty for SunOS4 is broken: run under Solaris"
endif

if ($1 == "") then
    echo ""
    echo "usage: `basename $0` [dotty arguments] file"
    echo ""
    echo "dotty arguments: [-V] [-lm (sync|async)] [-el (0|1)]"
    echo ""
    echo "examples:"
    echo ""
    echo "dotty.sh my.dot"
    echo ""
    echo "$0 -V comm_lexrel_brief.dot"
    echo ""
    exit
endif

# Invoke dotty script
# note: it is now leading to some 'echo: No match' warning which is ignored
## nice +9 ${GRAPHVIZ_HOME}/$OSTYPE/bin/dotty.bsh $* &
nice +9 ${GRAPHVIZ_HOME}/$OSTYPE/bin/dotty.bsh $* |& grep -v 'echo: No match' &
