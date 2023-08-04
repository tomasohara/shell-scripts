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

# convert-emoticons-aux(cmd, arg, ...): rens command and converts emoticons to text
# ex: convert-emoticons-aux black /tmp/__init__.py
# note: stderr redirected onto stdout
function convert-emoticons-aux {
    "$@" 2>&1 | convert_emoticons.py -
    }


#...............................................................................

# Python stuff
## OLD: alias plint=python-lint
simple-alias-fn plint 'PAGER=cat python-lint'
alias-fn plint-torch 'plint "$@" | grep -v "torch.*no-member"'
#
# clone-repo(url): clone github repo at URL into current dir with logging
function clone-repo () {
    local url repo log
    url="$1"
    ## OLD: repo=$(basename "$url")
    repo=$(basename "$url" .git)
    log="_clone-$repo-$(T).log"
    ## OLD: command script "$log" git clone "$url"
    # maldito linux: -c option required for command for
    # shellcheck disable=SC2086
    if [ "$(under-linux)" = "1" ]; then
	command script "$log"  -c "git clone '$url'"
    else
	command script "$log"  git clone "$url"
    fi
    #
    ls -R "$repo" >> "$log"
    ## Note: output warning that script now done (to avoid user closing the window assuming script active)
    ## TODO: add trace-stderr
    echo "FYI: script-based clone done (see $log)" 1>&2
}
simple-alias-fn black-plain 'convert-emoticons-aux black'

# run-python-script(script, args): run SCRIPT with ARGS with output to _base-#.out
# and stderr to _base-#.log where # is value of global $_PSL_.
# note: Checks for errors afterwards.
function run-python-script {
    ## DEBUG: trace-vars _PSL_ out_base log
    if [ "$1" = "" ]; then
        echo "Usage: $0 script arg ..."
        return
    fi
    # Check args
    local script_path="$1";
    shift;
    local script_args="$*";
    local script_base
    script_base=$(basename-with-dir "$script_path" .py);
    #
    # Run script and check for errors
    let _PSL_++;
    local out_base
    out_base="$script_base.$(TODAY).$_PSL_";
    local log="$out_base.log";
    ## DEBUG: trace-vars _PSL_ out_base log
    # TODO2: fix _PSL_ value retention
    _PSL_=666; command rm -v "$out_base.out" "$log";
    # shellcheck disable=SC2086
    echo "$script_args" | DEBUG_LEVEL=4 $PYTHON "$script_path" - > "$out_base.out" 2> "$log";
    check-errors-excerpt "$log";
    tail "$log" "$out_base.out"
}

#...............................................................................

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
simple-alias-fn act-plain 'convert-emoticons-aux act'


# para-len-alt(file, ...): show length of each paragraph with embedded newlines replaced with CR's to allow chaining
# note: strips the 0-len paragraph indicator
function para-len-alt { perl -00 -pe 's/\n(.)/\r$1/g;' "$@" | line-len | perl -pe 's/^0\t//;'; }

# Bash stuff
# shell-check-last-snippet(notes-file): extract last Bash snippet from notes
# file and run through shellcheck
# The snippet should be bracketted by lines with "$: {" and "}"
function shell-check-last-snippet {
    # shellcheck disable=SC2002
    cat "$1" | perl -0777 -pe 's/^.*\$:\s*\{(.*)\n\s*\}\s*[^\{]*$/$1\n/s;' | shell-check --shell=bash -;
}
#
# shell-check-stdin(): run shell-check over stdin
function shell-check-stdin {
    ## DEBUG: echo "in shell-check-stdin: args='$*'"
    ## BAD:
    ## local snippet
    ## read -d . -p $'Enter snippet lines with single . on end line\n' snippet
    ## ## DEBUG: echo "$snippet"
    ## trace-vars snippet
    ## shell-check - <<<"$snippet"
    ## DEBUG: cat <<<"$snippet"
    ## echo "out shell-check-stdin"
    echo "Enter snippet lines and then ^D"
    python -c 'import sys; sys.stdin.read()' | shell-check -
    if [ "$?" -eq 0 ]; then echo "shellcheck OK"; fi
}

# tabify(text): convert spaces in TEXT to tabs
# TODO: account for quotes
function tabify {
    perl -pe 's/ /\t/;'
}
# trace-vars(var, ...): trace each VAR in command line
# note: output format: VAR1=VAL1; ... VARn=VALn;
function trace-vars {
    local var value
    for var in "$@"; do
	# shellcheck disable=SC2027,SC2046
	## echo -n "$var="$(eval echo "\$$var")"; "
	## TODO: value="$(eval "echo \$$var")"
	value="$(set | grep "^$var=")"
	## BAD: echo -n "$var=$value; "
	echo -n "$value; "
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

# remote-prompt([prompt="_nickname[0]"@]): set prompt to _N@ where N is first letter of host nickname
function remote-prompt {
    local prompt="$1"
    if [ "$prompt" = "" ]; then prompt="_$(echo "$HOST_NICKNAME" | perl -pe 's/^(.).*/$1/;')@"; fi
    reset-prompt "$prompt"
}

#...............................................................................
# Organizer stuff

# rename-adhoc-notes(): rename adhoc notes under $PWD from HOST-adhoc-notes to {dir-basename}-adhoc-notes-HOST
# shellcheck disable=SC2016
alias-fn rename-adhoc-notes 'rename-files -q "$(get-host-nickname)-adhoc-notes" "$(basename $PWD)-adhoc-notes-$(get-host-nickname)"'

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
	# TODO: derive timestamp via rename-with-file-date (in case last snapshit taken earlier)
	new_name="$new_name-$(T).png"
    fi
    local last_file
    # TODO: have options to use latest file (regardless of name) 
    # shellcheck disable=SC2010
    last_file="$(ls -t ~/Pictures/*.png | grep -i '/screen.*shot' | head -1)"
    move "$last_file" "$new_name"		
}

#................................................................................
# Media related
#
# fix-transcript-timestamp(): put text on same line in YouTube transcripts
alias-fn fix-transcript-timestamp 'perl -i.bak -pe "s/(:\d\d)\n/\1\t/;" "$@"'

#...............................................................................
# System stuff

# host-nickname(): return HOST_NICKNAME or ~/.host-nickname or tpo-host
function get-host-nickname {
    local nickname="$HOST_NICKNAME"
    if [ "$nickname" = "" ]; then
	nickname="$(grep -v '^#' ~/.host-nickname 2> /dev/null)"
    fi
    if [ "$nickname" = "" ]; then
	nickname="tpo-host"
    fi
    echo "$nickname"
}

#...............................................................................
# Archive related

# create-zip(dir): create zip archive with DIR
# note: -r for recursive and -u for update
function create-zip {
    local dir="$1"
    shift
    if [ "$dir" = "" ]; then
	echo "Usage create-zip [dirname]"
	echo "ex: create-zip /mnt/resmed"
	## echo "Usage: $BASH_SOURCE[0] [dirname]"
	## echo "ex: $BASH_SOURCE[0] /mnt/resmed"
	return
    fi
    local archive
    archive="$TEMP/$(basename "$dir").zip"
    echo "issuing: zip -r -u \"$archive\" \"$dir\""
    zip -r -u "$archive" "$dir";
}
#
# create-zip-dir(dir): create zip of dir in context of parent
function create-zip-from-parent {
    local path="$1"
    local dir
    dir="$(basename "$path")"
    pushd "$(realpath "$path/..")";
    create-zip "$dir"
    popd
}

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

# sleep-for(seconds, [message]): sleep for SECONDS with MESSAGE ("delay for Ns")
function sleep-for {
    local sec="$1"
    local msg="${2:-"delay for ${sec}s"}"
    echo "$msg"
    sleep "$sec"
}

#...............................................................................
# Emacs related

# reset-under-emacs: clear settings added for Bash under emacs
# note: for use in external terminal invoked under Emacs term (e.g., via gterm)
function reset-under-emacs {
    unset UNDER_EMACS SCRIPT_PID
    all-tomohara-settings
}

#................................................................................
# Idiosyncratic stuff (n.b., doubly so given "tomohara-proper" part of filename)
# note: although 'kill-it xyz' is not hard to type 'kill-xyz' allows for tab completion
#
## OLD: alias all-tomohara-settings='tomohara-aliases; tomohara-settings; more-tomohara-aliases; tomohara-proper-aliases'
alias all-tomohara-aliases='source $TOM_BIN/all-tomohara-aliases-etc.bash'
alias all-tomohara-settings='all-tomohara-aliases; tomohara-settings'
#
alias kill-kdiff3='kill-it kdiff3'
alias kill-firefox='kill-it firefox'
alias kill-jupyter='kill-it jupyter'
