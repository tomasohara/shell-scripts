#! /usr/bin/env bash
#
# tomohara-proper-aliases.bash: aliases not intended for general consumption
# (e.g., new location for idiosyncratic stuff in tomoohara-aliases.bash)
#
# note:
# - Maldito shellcheck (i.e., lack of mnemonic codes on top of nitpicking):
#   SC2002 (style): Useless cat. Consider 'cmd < file | ..' or 'cmd file | ..' instead.
#   SC2010 (warning): Don't use ls | grep. Use a glob or a for loop with a condition to allow non-alphanumeric filenames.
#   SC2016 (info): Expressions don't expand in single quotes
#   SC2027 (warning): The surrounding quotes actually unquote this.
#   SC2046: Quote this to prevent word splitting
#   SC2086: Double quote to prevent globbing)
#   SC2181: Check exit code directly with e.g. 'if mycmd;', not indirectly with $?.
#

# Change git-xyz-plus to git-xyz- for sake of tab completion
# TODO: automate the derivation of the following (e.g., drop 'plus' or 'alias' suffix)
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

# convert-emoticons-aux(cmd, arg, ...): runs command and converts emoticons to text
# ex: convert-emoticons-aux black /tmp/__init__.py
# note: stderr redirected onto stdout
function convert-emoticons-aux {
    "$@" 2>&1 | convert_emoticons.py -
    }

#...............................................................................

# Python stuff
simple-alias-fn plint 'PAGER=cat python-lint'
alias-fn plint-torch 'plint "$@" | grep -v "torch.*no-member"'
#
# clone-repo(url): clone github repo at URL into current dir with logging
function clone-repo () {
    local url repo log
    url="$1"
    repo=$(basename "$url" .git)
    log="_clone-$repo-$(T).log"
    # maldito linux: -c option required for command for
    # shellcheck disable=SC2086
    if [ "$(under-linux)" = "1" ]; then
        command script "$log"  -c "git clone '$url'"
    else
        command script "$log"  git clone "$url"
    fi
    #
    ls -R "$repo" >> "$log"
    ## Note: outputs warning that script now done (to avoid user closing the window assuming script active)
    ## TODO: add trace-stderr
    echo "FYI: script-based clone done (see $log)" 1>&2
}
simple-alias-fn black-plain 'convert-emoticons-aux black'

# run-python-script(script, args): run SCRIPT with ARGS with output to _base-#.out
# and stderr to _base-#.log where # is value of global $_PSL_.
# The arguments are passed along unless USE_STDIN is 1.
# note: Checks for errors afterwards. Use non-locals _PSL_, out_base and log.
function run-python-script {
    ## DEBUG: trace-vars _PSL_ out_base log
    if [ "$1" = "" ]; then
        echo "Usage: [USE_STDIN=B] run-python-script script arg ..."
        return
    fi
    # Check args
    local script_path="$1";
    shift;
    local script_args=("$@");
    local script_base
    script_base=$(basename-with-dir "$script_path" .py);
    #
    # Run script and check for errors
    # note: $_PSL_, $log and $out are not local, so available to user afterwards
    local out_base
    let _PSL_++;
    out_base="$script_base.$(TODAY).$_PSL_";
    log="$out_base.log";
    out="$out_base.out";
    ## DEBUG: trace-vars _PSL_ out_base log
    rename-with-file-date "$out_base.out" "$log";
    # shellcheck disable=SC2086
    local python_arg="-"
    # shellcheck disable=SC2086
    {
	if [ "${USE_STDIN:-0}" = "1" ]; then
	    # note: assumes python script uses - to indicate stdin as per norm for mezcla
	    echo "${script_args[*]}" | $PYTHON "$script_path" $python_arg > "$out" 2> "$log";
	else
	    # note: disables - with explicit arguments or if running pytest
	    if [[ ("${script_args[*]}" != "") || ($PYTHON =~ pytest) ]]; then python_arg=""; fi
	    $PYTHON "$script_path" "${script_args[@]}" $python_arg > "$out" 2> "$log";
	fi
    }
    tail "$log" "$out" | truncate-width
    check-errors-excerpt "$log";
}

# test-python-script(test-script): run TEST-SCRIPT via  pytest
function test-python-script {
    local default_pytest_opts="-vv --capture=tee-sys"
    if [ "$1" = "" ]; then
        echo "Usage: [PYTEST_OPTS=["$default_pytest_opts"]] test-python-script script"
        return
    fi
    PYTEST_OPTS="${PYTEST_OPTS:-"$default_pytest_opts"}"
    PYTHONUNBUFFERED=1 PYTHON="pytest $PYTEST_OPTS" run-python-script "$@";
}

# color-test-failures(): show color-coded test result (yellow for xfailed and red for regular fail)
function color-test-failures {
    cat "$@" | colout "\bfailed" red | colout "xfailed" yellow | colout "\bpassed" green | colout "xpassed" green faint;
}

# ocr-image(image-filename): run image through optical character recognition (OCD)
alias-fn ocr-image-old 'tesseract "$@" -'
alias-fn ocr-image 'tesseract "$1" "$1".ocr'

#...............................................................................

# JSON stuff
function json-validate () {
    local file="$1"
    python -c "import json; from mezcla import system; print(json.loads(system.read_file('$file')))" | head -5 | truncate-width
}

# Misc. stuff
function script-config {
    mkdir -p ~/config
    script ~/config/"_config-$(T).log"
}
simple-alias-fn act-plain 'convert-emoticons-aux act'


# para-len-alt(file, ...): show length of each paragraph with embedded newlines replaced with CR's to allow chaining
# note: strips the 0-len paragraph indicator
function para-len-alt { perl -00 -pe 's/\n(.)/\r$1/g;' "$@" | line-len | perl -pe 's/^0\t//;'; }

#...............................................................................
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
    echo "Enter snippet lines and then ^D"
    python -c 'import sys; sys.stdin.read()' | shell-check -
    # shellcheck disable=SC2181
    if [ "$?" -eq 0 ]; then echo "shellcheck OK"; fi
}

# tabify(text): convert spaces in TEXT to tabs
# TODO: account for quotes
function tabify {
    perl -pe 's/ /\t/g;'
}
# trace-vars(var, ...): trace each VAR in command line
# note: output format: VAR1=VAL1; ... VARn=VALn;
function trace-vars {
    local var value
    for var in "$@"; do
        ## TODO3: get old eval/echo approach to work in general
        ## # shellcheck disable=SC2027,SC2046
        ## echo -n "$var="$(eval echo "\$$var")"; "
        ## TODO: value="$(eval "echo \$$var")"
        ## NOTE: See https://stackoverflow.com/questions/11065077/the-eval-command-in-bash-and-its-typical-uses
        ## OLD:
        ## value="$(set | grep "^$var=")"
        ## echo -n "$value; "
        echo -n "$var="$(eval echo "\${$var}")"; "
        ## TODO: echo -n "$value; " 1>&2
    done
    echo
    ## TODO: echo 1>&2
}
# trace-array-vars(var, ...): trace each ARRAY in command line
# note: output format: ARR1=(VAL11 ... VAL1n); ARR2=(VAL21 ... VAL2n);
function trace-array-vars {
    local var
    for var in "$@"; do
        # note: ignores SC1087 (error): Use braces when expanding arrays
        # shellcheck disable=SC2027,SC2046,SC1087
        ## OLD: echo -n "$var="$(eval echo "\${$var[@]}")"; "
        echo -n "$var=("$(eval echo "\${$var[@]}")"); "
    done
    echo
}

# remote-prompt([prompt="_nickname[0]"@]): set prompt to _N@ where N is first letter of host nickname
function remote-prompt {
    local prompt="$1"
    if [ "$prompt" = "" ]; then prompt="_$(echo "$HOST_NICKNAME" | perl -pe 's/^(.).*/$1/;')@"; fi
    reset-prompt "$prompt"
}

# pristine-bash(): invoke Bash with fresh environment, with prompt to 'pristine $' as a reminder
function pristine-bash {
    env --ignore-environment PS1='pristine $ ' bash --noprofile --norc
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
        return
    fi
    local archive
    archive="$TEMP/$(basename "$dir").zip"
    echo "issuing: zip -r -u \"$archive\" \"$dir\""
    zip -r -u "$archive" "$dir";
}
#
# create-zip-dir(dir=pwd): create zip of DIR in context of parent
function create-zip-from-parent {
    local path="${1:-$PWD}"
    local dir
    dir="$(basename "$path")"
    pushd "$(realpath "$path/..")";
    create-zip "$dir"
    popd
}
alias zip-from-parent=create-zip-from-parent

#................................................................................
# Linux stuff
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

# image-metadata(file): show metadata about image (e.g., associated text)
simple-alias-fn image-metadata 'identify -verbose'
# show-sd-prompts(file): show keywords in image file for Stable Diffusion prompts
function show-sd-prompts { image-metadata "$@" | egrep --text --ignore-case '(parameters|(negative prompt)):'; }

#...............................................................................
# Linux admin

alias free-memory='free --wide --human | grep -v Swap:'
# TODO: get this to work completely
simple-alias-fn clear-cache 'free-memory | grep -v Admin; sysctl vm.drop_caches=1; free-memory'

#...............................................................................
# Emacs related

# reset-under-emacs: clear settings added for Bash under emacs
# note: for use in external terminal invoked under Emacs term (e.g., via gterm)
function reset-under-emacs {
    unset UNDER_EMACS SCRIPT_PID
    all-tomohara-settings
}

#................................................................................
# Media stuff

# make-screencast-video: produce video capturing the screen interaction
alias make-screencast-video=kazam

#-------------------------------------------------------------------------------
# Other stuff

# oscar: run Open Source CPAP Analysis Reporter
alias oscar="run-app OSCAR"

# 1pass: run 1password (snap)
alias 1pass="run-app 1password"

#................................................................................
# Doubly idiosyncratic stuff (i.e., given "tomohara-proper" part of filename)
# note: although 'kill-it xyz' is not hard to type 'kill-xyz' allows for tab completion
#
alias tomohara-proper-aliases='source "$TOM_BIN/tomohara-proper-aliases.bash"'
alias all-tomohara-aliases='source $TOM_BIN/all-tomohara-aliases-etc.bash'
alias all-tomohara-settings='all-tomohara-aliases; tomohara-settings'
#
alias kill-kdiff3='kill-it kdiff3'
alias kill-firefox='kill-it firefox'
alias kill-jupyter='kill-it jupyter'
alias kill-chromiun='kill-it chromium'
alias kill-sleep='kill_em.sh sleep'
