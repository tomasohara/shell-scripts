# rsh-aliases.bash: rsh aliases for use in do_setup.bash
# 
# NOTES;
# - Separated out due to stupid bash version difference: the solaris
# version (2.03.0) doesn't support interated for loop, unless linux
# version (2.05a.0).
#

function rsh-list() { ps_mine.sh | cut -c10-15,51-512 | grep -v grep | egrep "(PID|rsh)" | perl -pe "s#/home/[^ ]+/([^ ]+)\b#\1#g;" | egrep -v "rsh <(zombie|defunct)>" | $PAGER_CHOPPED
}
alias old-rsh-list='ps_mine.sh | grep -v grep | grep rsh | perl -pe "s/.* S //;" | perl -pe "s#/home/[^ ]+/([^ ]+ )#\1#g;" | less -S'
alias rsh-count='rsh-list | wc';
alias crsh=rsh-count;
alias medusa='rsh medusa'
alias wb1='rsh wb1'
alias wb2='rsh wb2'
alias wb3='rsh wb3'
# TODO: generate all via a for or while loop
alias wb30='rsh wb30'
alias wb31='rsh wb31'
alias wb32='rsh wb32'
#
alias colossus='rsh colossus'
for (( i = 1; i <= 32; i++ )); do
    alias bw$i="rsh bw$i"; 
done
