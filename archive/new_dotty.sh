#! /bin/csh -f
#
# dotty.sh: sets the environment for dotty and then invokes it
#
# dotty is AT&T's DAG graphing utility (part of graphviz)
#

if ($#GRAPHLING_HOME == 0) setenv GRAPHLING_HOME /home/graphling
setenv GRAPHVIZ_HOME ${GRAPHLING_HOME}/TOOLS/GRAPHVIZ/
setenv LEFTYPATH ${GRAPHVIZ_HOME}/sun4/lib/lefty/
setenv PATH ${PATH}:${GRAPHVIZ_HOME}/sun4/bin
nice +9 ${GRAPHVIZ_HOME}/sun4/bin/dotty.bsh $* &
