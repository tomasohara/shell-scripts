#! /usr/bin/env bash
#
# tomohara-proper-aliases.bash: aliases not intended for general consumption
# (e.g., new location for idiosyncratic stuff in tomoohara-aliases.bash)
#
# note:
# - Maldito shellcheck (i.e., lack of menomic codes on top of nitpicking):
#   SC2002 (style): Useless cat. Consider 'cmd < file | ..' or 'cmd file | ..' instead.
#   SC2010 (warning): Don't use ls | grep. Use a glob or a for loop with a condition to allow non-alphanumeric filenames.
#   SC2016 (info): Expressions don't expand in single quotes
#   SC2027 (warning): The surrounding quotes actually unquote this.
#   SC2086: Double quote to prevent globbing)
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
alias-fn plint-torch 'plint "$@" | grep -v "torch.*no-member"'
#
# clone-repo(url): clone github repo at URL into current dir with logging
function clone-repo () {
    local url repo log
    url="$1"
    repo=$(basename "$url")
    log="_clone-$repo-$(T).log"
    ## OLD: command script "$log" git clone "$url"
    # maldito linux: -c option required for command for
    local command_indicator=""
    if [ "$(under-linux)" = "1" ]; then
	command_indicator="-c"
    fi
    #
    # shellcheck disable=SC2086
    command script "$log" $command_indicator git clone "$url"
    ls -R "$repo" >> "$log"
    ## Note: output warning that script now done (to avoid user closing the window assuming script active)
    ## TODO: add trace-stderr
    echo "FYI: script-based clone done (see $log)" 1>&1
}

# JSON stuff
function json-validate () {
    local file="$1"
    python -c "import json; from mezcla import system; print(json.loads(system.read_file('$file')))" | head -5 | truncate-width
}

# Misc. stuff
## OLD: alias script-config='script ~/config/_config-$(T).log'
function script-config {
    mkdir -p ~/config
    script ~/config/"_config-$(T).log"
}

# para-len-alt(file, ...): show length of each paragraph with embedded newlines replaced with CR's to allow chaining
# note: strips the 0-len paragraph indicator
function para-len-alt { perl -00 -pe 's/\n(.)/\r$1/g;' "$@" | line-len | perl -pe 's/^0\t//;'; }

# Bash stuff
# shell-check-last-snippet(notes-file): extract last Bash snippet from notes
# file and run through shellcheck
# The snippet should be bracketted by lines with "$: {" and "}"
function shell-check-last-snippet {
    # shellcheck disable=SC2002
    cat "$1" | perl-grep -v '^\s*#' | perl -0777 -pe 's/^.*\$:\s*\{(.*)\n\s*\}\s*[^\{]*$/$1\n/s;' | shell-check --shell=bash -;
}
# tabify(text): convert spaces in TEXT to tabs
# TODO: account for quotes
function tabify {
    perl -pe 's/ /\t/;'
}
# trace-vars(var, ...): trace each VAR in command line
# note: output format: VAR1=VAL1; ... VARn=VALn;
function trace-vars {
    local var
    for var in "$@"; do
	# shellcheck disable=SC2027,SC2046
	echo -n "$var="$(eval echo "\$$var")"; "
    done
    echo
    ##
    ## TAKE 1
    ## local var_spec="$*"
    ## echo "$var_spec" | tabify
    ##  echo $(eval echo $var_spec | tabify)
}
# trace-array-vars(var, ...): trace each ARRAY in command line
# note: output format: VAR1=VAL1; ... VARn=VALn;
function trace-array-vars {
    local var
    for var in "$@"; do
	# note: ignores SC1087 (error): Use braces when expanding arrays
	# shellcheck disable=SC2027,SC2046,SC1087
	echo -n "$var="$(eval echo "\${$var[@]}")"; "
    done
    echo
}

#................................................................................
# Snapshot related

# rename-last-snapshot(new-name): rename most recent snapshot to NEW-NAME (excluding renamed files)
# Note: includes dated suffix unless date-like one used
# example:
#    $ rename-last-snapshot "sagemaker-users.pnmg"
#    "Screen Shot 2023-02-01 at 12.21.06 PM.png" -> "sagemaker-users.pnmg"
function rename-last-snapshot {
    local new_name="$1"
    # Append dated image suffix unless date-like suffix w/ extension used
    if [[ ! "$new_name" =~ [0-9][0-9]*.png ]]; then
	new_name="$new_name-$(T).png"
    fi
    local last_file
    # shellcheck disable=SC2010
    last_file="$(ls -t ~/Pictures/*.png | grep -i '/screen.*shot' | head -1)"
    move "$last_file" "$new_name"		
}

#................................................................................
# Media related
#
# fix-transcript-timestamp(): put text on same line in YouTube transcripts
alias-fn fix-transcript-timestamp 'perl -i.bak -pe "s/(:\d\d)\n/\1\t/;" "$@"'

#................................................................................
# Linux stuff
## TEMP:
quiet-unalias ps-time
# shellcheck disable=SC2016
alias-fn ps-time 'LINES=1000 COLUMNS=256 ps_sort.perl -time2num -num_times=1 -by=time - 2>&1 | $PAGER'
#
# screen-reattach: restart GNU screen session
# options: -d -RR: reattach a session and if necessary detach or create it
alias-fn screen-reattach 'screen -d -RR'

#................................................................................
# Idiosyncratic stuff (n.b., doubly so given "tomohara-proper" part of filename)
alias all-tomohara-settings='tomohara-aliases; tomohara-settings; more-tomohara-aliases; tomohara-proper-aliases'
alias kill-kdiff3='kill-it kdiff3'
