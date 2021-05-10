# svn-aliases.bash: rsh aliases for use in do_setup.bash (or .bashrc)
#
# usage:
#    source ~/bin/svn-aliases.bash
#
# TODO: ~/bin => ~/tpo-bin where ~/tpo-bin => ~tomohara/bin
#

# SVN stuff
#
# SVN options used:
#  -r REV  use revision REV
# diff options (see diff.sh):
#  -w   ignore white space when comparing lines
#  -b	ignore changes in amount of white space
#  -B	ignore changes that just insert or delete blank lines
trace SVN stuff
#
# svn-aux(command-line): Runs svn COMMAND-LINE and pipe into less
#
function svn-aux () { svn "$@" >| /tmp/svn_.$$ 2>&1; $PAGER /tmp/svn_.$$; }
function svn-filtered () { filter=$1; shift; svn "$@" 2>&1 >| /tmp/svn_.$$ 2>&1; $GREP -v "$filter" /tmp/svn_.$$ | $PAGER; }
#
function svn-diff-filtered () { svn-filtered "^svn diff: Diffing" diff --diff-cmd diff.sh "$@" | $PAGER -p "^Index"; }
# BAD: alias svn-diff='svn-aux diff --diff-cmd ~/bin/diff.sh'
alias svn-diff='svn-aux diff --diff-cmd ~/bin/diff.bash'
# OLD: alias svn-vdiff='svn-aux diff --diff-cmd ~/bin/kdiff3.sh'
function svn-vdiff () { svn diff --diff-cmd ~/bin/kdiff3.sh "$@" & }
alias svn-cat='svn-aux cat'
alias svn-get='svn-aux update'
alias svn-get-read-only='svn-cat'
alias svn-put='svn-aux commit'
alias svn-log='svn-aux log'
alias svn-update='svn-aux update'
alias svn-status='svn-aux status'
# TODO: finish conversion from csv to svn
    # TODO: -d (cvs update's create missing directory) => ???
    alias svn-update-filtered='echo TODO: svn-filtered "^svn update" update -d'
    alias svn-update-latest='echo TODO: svn-filtered "^svn update" update -A'
    alias svn-examine='echo TODO: svn-filtered "^svn update" -n update -d'
    alias svn-modified='echo TODO: svn-aux status | $GREP Modified | extract_matches.perl "File: (\S+)" | echoize'
#
alias svn-modules='svn-aux checkout -c'
alias svn-annotate='svn-aux annotate'
alias svn-extract-all='extract_all_versions.perl -svn'
#
# svn-update-all: performs 'svn update' grepping for conflicts and changes
#
function svn-update-all () { 
    svn update -d "$@" >| /tmp/update-$$.log 2>&1; 
    $GREP "^C" /tmp/update-$$.log >| /tmp/all-update-$$.log; 
    cat /tmp/update-$$.log >> /tmp/all-update-$$.log; 
    less -+F -+I -p "^(U|C|M|Merging|(svn (update|server)))" /tmp/all-update-$$.log;
    }

# Convenience aliases
alias svn-kdiff='svn-vdiff'
# Create dummy csv-xyz aliases mapping into svn version
svn_aliases=`alias | extract_matches.perl "alias svn-(\S+)="`
for alias in $svn_aliases; do alias csv-$alias="svn-$alias"; done
