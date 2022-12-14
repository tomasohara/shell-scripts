#! /usr/bin/env bash
#
# tomohara-proper-aliases.bash: aliases not intended for general consumption
#

# Change git-xyz-plus to git-xyz- for sake of tab completion
# TODO: automate following
alias git-add-='git-add-plus'
alias git-diff-='git-diff-plus'
alias git-difftool-='git-difftool-plus'
alias git-log-='git-log-plus'
alias git-update-='git-update-plus' 
alias git-vdiff='git-vdiff-alias '
## TODO: alias git-X-='git-X-plus'

# Other misc. stuff
alias nvidia-batched='batch-nvidia-smi.sh'
alias nvidia-top='nvtop'

# Python stuff
alias plint=python-lint

# Misc. stuff
alias script-config='script ~/config/_config-$(T).log'
alias-fn ps-time 'LINES=1000 COLUMNS=256 ps_sort.perl -time2num -num_times=1 -by=time - 2>&1 | $PAGER'
