# Tom's settings related to Juju work
#
# NOTE:
# - older version subsumed by tohara-setup.bash
#
# TODO:
# - reconcile with ~/bin/linux-setup.bash
# - rename as tohara-setup.bash
#

# Adhoc settings
## function kdiff() { kdiff.sh "$@" & }
#
## ec2_host="ec2-184-73-51-232.compute-1.amazonaws.com"
## main_ec2_host=$ec2_host
## alt_ec2_host="ec2-23-22-242-37.compute-1.amazonaws.com"
## proto_ec2_host="ec2-54-80-170-36.compute-1.amazonaws.com"
#
## function ssh-ec2-tpo () { ssh -X -i ~/.ssh/juju-id_rsa  root@$1; }
## function scp-ec2-up() { local host="$1"; shift; scp -i ~/.ssh/juju-id_rsa "$@"  root@$host:xfer; }
## ## function scp-ec2-down() { scp -i ~/.ssh/juju-id_rsa root@$ec2_host:xfer/$1 .; }
## function scp-ec2-down() { local host="$1"; shift; for _file in "$@"; do scp -i ~/.ssh/juju-id_rsa root@$host:xfer/$_file .; done; }
## alias juju-upload="scp-ec2-up $ec2_host"
## alias juju-download="scp-ec2-down $ec2_host"
## alias juju-upload-alt="scp-ec2-up $alt_ec2_host"
## alias juju-upload-proto="scp-ec2-up $proto_ec2_host"
## alias juju-download-alt="scp-ec2-down  $alt_ec2_host"
## alias juju-download-proto="scp-ec2-down  $proto_ec2_host"
## alias juju-login="ssh-ec2-tpo $ec2_host"
## alias juju-login-alt="ssh-ec2-tpo $alt_ec2_host"
## alias juju-login-proto="ssh-ec2-tpo $proto_ec2_host"
#
## alias ssh-juju=juju-login
## ## OLD function gr-juju-notes () { grepl "$@" ~/juju/*notes* $JJDATA/juju-data/*notes*; }
## function gr-juju-notes () { grepl "$@" ~/juju/*notes* $JJDATA/*notes*; }
## function gr-juju-notes-archive () { MY_GREP_OPTIONS="" grepl "$@" ~/juju/_note-archive.list; }
#
## alias restart-network='sudo ifdown eth0; sudo ifup eth0'
## alias ssh-host-juju='ssh -i ~/.ssh/juju-id_rsa'
# TODO: remove following (to minimize import failures by others due to implicit dependencies); see what the default Juju PYTHONPATH should be"
## export PYTHONPATH="$SANDBOX:/home/tomohara/my-sandbox/src/tuber:/home/tomohara/my-sandbox/src:$PYTHONPATH"
## OLD: export SANDBOX="/d/data/juju-data"
## OLD: export SRC="$SANDBOX/src"
#
# TODO: check first for /mnt/$USER/juju
# TODO: add conditional-export alias
## if [ "$JJDATA" == "" ]; then export JJDATA="/d/data/juju-data"; fi
## if [ "$SRC" == "" ]; then export SRC="$JJDATA/src"; fi
## if [ "$SANDBOX" == "" ]; then export SANDBOX="$SRC/sandbox/tohara"; fi
## if [ "$QLOG_SRC" == "" ]; then export QLOG_SRC="$SRC/query-log-analysis"; fi

# Eventual additions to do_setup/bash
#
# Python helpers
## OLD: alias ps-python='ps_mine.sh --all | grep -i python'
## alias show-python-path='show-path-dir PYTHONPATH'
## function python-lint() { pylint "$@" 2>&1 | egrep -v '((Unnecessary parens)|(Line too long)|(Trailing whitespace)|(TODO)|(Undefined variable))' 2>&1 | $PAGER; }
#
## # Make sure tab completion not escaped for directory names
## shopt -s direxpand
#
## alias remove-force='delete-force'
## alias remove-dir-force='/bin/rm -rfv'
## alias delete-dir-force='remove-dir-force'
 
# Mercurial (hg) aliases
## function hg-pull-and-update() {
##         if [ "" = "$(grep ^repo ~/.hgrc)" ]; then echo "*** Warning: fix ~/.hgrc for read-only access ***"; else
##             hg="python -u /usr/bin/hg"; log_file=_hg-update-$(date '+%d%b%y').log; ($hg pull --noninteractive --verbose; $hg update --noninteractive --verbose) >| $log_file 2>&1; less $log_file
##         fi;
## }
## function hg-push() {
##     if [ "" != "$(grep ^repo ~/.hgrc)" ]; then echo "*** Warning: fix ~/.hgrc for read-write access ***"; else 
##        hg push --verbose
##     fi;
## }
## function hg-diff () { hg diff "$@" 2>&1 | less -p '^diff'; }

# Web access
#
## function curl-dump () {
##     local url="$1";
##     local base=`basename $url`;
##     curl $url > $base;
## }


# Add sandbox to environment
# TODO: make optional
## echo "Adding sandbox to environment"
## source $SANDBOX/adhoc.bash >| /dev/null
## setup-get_logistic_regression_inputs /mnt/tohara/src

# Linux admin
## alias apt-install='apt-get install --fix-missing'
## alias apt-search='apt-cache search'

# Get remaining settings from ~/bin/tpo_setup.bash
## if [ -e ~/bin/do_setup.bash ]; then source ~/bin/do_setup.bash; fi

# Adhoc fixup's
## wn=/usr/bin/wn
## cygwin_wordnet_dir="/c/cygwin/lib/wnres/dict"
## if [[ ("$WNSEARCHDIR" = "") && (-e $cygwin_wordnet_dir) ]]; then
##     export WNSEARCHDIR=$cygwin_wordnet_dir
## fi
