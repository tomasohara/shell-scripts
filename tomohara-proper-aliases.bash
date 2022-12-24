#! /usr/bin/env bash
#
# tomohara-proper-aliases.bash: aliases not intended for general consumption
#
# note:
# - Maldito shellcheck (i.e., lack of menomic codes):
#   SC2016 (info): Expressions don't expand in single quotes
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
alias nvsmi=nvidia-smi

# Python stuff
alias plint=python-lint
alias-fn plint-torch 'plint "$@" | grep -v torch.*no-member'
#
# clone-repo(url): clone github repo at URL into current dir with logging
function clone-repo () {
    local url repo log
    url="$1"
    repo=$(basename "$url")
    log="_clone-$repo-$(T).log"
    command script "$log" git clone "$url"
    ls -R "$repo" >> "$log"
}

# Misc. stuff
alias script-config='script ~/config/_config-$(T).log'

# Bash stuff
# shell-check-last-snippet(notes-file): extract last Bash snippet from notes
# file and run through shellcheck
# The snippet should be bracketted by lines with "$: {" and "}"
function shell-check-last-snippet {
  cat "$1" | perl -0777 -pe 's/^.*\$:\s*\{(.*)\}\s[^\{]+$/$1/s;' | shell-check --shell=bash -;
}

# Linux stuff
# shellcheck disable=SC2016
alias-fn ps-time 'LINES=1000 COLUMNS=256 ps_sort.perl -time2num -num_times=1 -by=time - 2>&1 | $PAGER'
