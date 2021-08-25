#! /bin/csh -f
#
# wnb.sh: runs the WordNet 1.6 browser (after setting up the environment)
#

if ($?GRAPHLING_HOME == 0) setenv GRAPHLING_HOME /home/graphling
unsetenv WNSEARCHDIR
setenv WNHOME ${GRAPHLING_HOME}/TOOLS/WORDNET-1.6
setenv MANPATH ${MANPATH}:$WNHOME/man
setenv WN_BINDIR $WNHOME/bin/$OSTYPE
setenv PATH ${WN_BINDIR}:${GRAPHLING_HOME}/TOOLS/TCLTK/bin:$PATH
setenv TCL_LIBRARY ${GRAPHLING_HOME}/TOOLS/TCLTK/lib/tcl7.6
setenv TK_LIBRARY ${GRAPHLING_HOME}/TOOLS/TCLTK/lib/tk4.2
rehash
wnb
