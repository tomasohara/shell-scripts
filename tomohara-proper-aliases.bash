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
alias git-all-update='update-main-repos.bash'
alias git-extract-all-versions='extract-all-git-versions.bash --human'
alias alt-git-extract-all-versions='alt-extract-all-git-versions.bash --human'
alias git-files-changed=git-diff-list
alias git-clone-alias='clone-repo'
alias git-script-update='script-update'
function git-repo-url { extract-matches 'url\s*=\s*(\S+)' "$(git-root-alias)/.git/config"; }
## TODO: alias git-X-='git-X-plus'
#
# Github
alias git-hide='git update-index --skip-worktree'
alias git-unhide='git update-index --no-skip-worktree'
alias git-hidden='git ls-files -v | grep -v ^H'
alias git-status-sans-tom="git-status | egrep -v '(^|[-_/.])tom([-_/.]|$)'"
alias git-status-tom=git-status-sans-tom
# TODO: work out better alias name
alias git-stat=git-status-sans-tom
# TODO: better name (e.g., git-diff-name-only-main?) and/or decompose git-name-diff-branch?
alias git-name-diff-main='git diff --name-only main..HEAD | cat'
#
# git-rename-revert(file, ...): renames FILE with data and then reverts
# note: uses touch to avoid extraneous error message
# TODO2: move into git-aliases.bash
function git-rename-revert {
    rename-with-file-date "$@" && touch "$@";
    git-revert-file-alias "$@";
}

# Other misc. stuff
alias nvidia-batched='batch-nvidia-smi.sh'
alias nvidia-batched-advanced='ADVANCED_USAGE=1 nvidia-batched -'
alias nvidia-top='nvtop'
alias nvsmi=nvidia-smi

# convert-emoticons-aux(cmd, arg, ...): runs command and converts emoticons to text
# ex: convert-emoticons-aux black /tmp/__init__.py
# note: stderr redirected onto stdout
function convert-emoticons-aux {
    "$@" 2>&1 | convert-emoticons-stdin
}

#...............................................................................
# Python stuff

# plint(...): shortcut for python-lint
simple-alias-fn plint 'PAGER=cat python-lint'
# shellcheck disable=SC2016
{
# plint-torch(...): pylint w/ torch no-member warnings, etc. ignored
alias-fn plint-torch 'plint "$@" | egrep -v "torch.*(no-member|no-name-in-module)"'
# plint-tester-testee(filename): run pylint over test file and tested file
## OLD: alias-fn plint-tester-testee 'plint "$1" tests/test_"$1"'
function plint-tester-testee {
    local script="$1"
    local test_script="tests/test_$script"
    plint "$script" "$test_script"
    if [ "${TEST:-0}" == "1" ]; then
        test-python-script "$test_script"
    fi
    }
}
#
# clone-repo(url): clone github repo at URL into current dir with logging
# TODO2: move to git-related section (better yet into git-aliases.bash)
function clone-repo () {
    local url repo log
    url="$1"
    repo=$(basename "$url" .git)
    log="_clone-$repo-$(T).log"
    # maldito linux: -c option required for command for
    # shellcheck disable=SC2086
    if [ "$(under-linux)" = "1" ]; then
        command script "$log" -c "git clone '$url'"
    else
        command script "$log" git clone "$url"
    fi
    #
    ls -R "$repo" >> "$log"
    check-errors-excerpt "$log"
    ## Note: outputs warning that script now done (to avoid user closing the window assuming script active)
    ## TODO: add trace-stderr
    echo "FYI: script-based clone done (see $log)" 1>&2
}
# black-plain(file): run black python reformatted over FILE filtering out emoticons
simple-alias-fn black-plain 'convert-emoticons-aux black'

# run-python-script(script, args): run SCRIPT with ARGS with output to dir/_base-#.out
# and stderr to dir/_base-#.log where # is value of global $_PSL_.
# The arguments are passed along unless USE_STDIN is 1.
# note: Checks for errors afterwards. Uses non-locals _PSL_, out_base and log.
function run-python-script {
    ## DEBUG: trace-vars _PSL_ out_base log
    if [ "$1" = "" ]; then
        echo "Usage: [ENV-OPTIONS] run-python-script script arg ..."
        echo "   ENV-OPTIONS: [USE_STDIN=B] [USE_STDOUT=B] [PROFILE_SCRIPT=B] [TRACE_SCRIPT=B] [PYTHON_DEBUG_LEVEL=n] [PYTHON_OUT_DIR=p] [KEEP_EMPTY_OUT=b] [PYTHON=path] [PYTHON_RUN_LABEL=str]"
        echo "note:"
        echo "- PYTHON_DEBUG_LEVEL uses 4 by default (unless regular DEBUG_LEVEL)"
        echo "- PYTHON_OUT_DIR is script dir unless a full path"
        return
    fi
    # Check args
    # note: "tests" might be specified for script (e.g., test-python-script tests)
    local script_path="$1"
    if [ ! -e "$script_path" ]; then
        script_path="$(which "$script_path")"
    fi
    shift
    local script_args=("$@")
    local script_dir
    script_dir="$(dirname "$script_path")"
    local script_base
    local default_out_dir="$script_dir"
    if [[ $default_out_dir =~ ^/.* ]]; then
        default_out_dir="."
    fi
    local out_dir="${PYTHON_OUT_DIR:-"$default_out_dir"}"
    script_base="$(basename "$script_path" .py)"
    # TODO: find shortcut for min
    local python_debug_level="${PYTHON_DEBUG_LEVEL:-4}"
    if [ "${DEBUG_LEVEL:-0}" -gt "$python_debug_level" ]; then
        python_debug_level="$DEBUG_LEVEL"
    fi  
    #
    # Run script and check for errors
    # note: $_PSL_, $log and $out are not local, so available to user afterwards
    # TODO3: rework to avoid problem with _PSL_ not being updated (or at least detect the error)!
    ## OLD:
    ## declare -g _PSL_ log out
    ## local out_base
    declare -g _PSL_ log out out_base PYTHON
    local module_spec=""
    let _PSL_++
    # TODO3: add OUT_BASE to override default
    local run_label="${PYTHON_RUN_LABEL:-"run"}"
    ## OLD: run_label=$(echo "$run_label" | perl -pe 'chomp; s/([^\.])$/\1\./;')
    run_label=$(echo "$run_label" | perl -pe 'chomp; s/\.$//;')
    out_base="$out_dir/_$script_base.$(TODAY).$run_label.$_PSL_"
    if [ "$PROFILE_SCRIPT" == "1" ]; then
       out_base="$out_base.profile"
       module_spec="-m cProfile -o $out_base.data"
    fi
    if [ "$TRACE_SCRIPT" == "1" ]; then
       out_base="$out_base.trace"
       module_spec="-m trace --trace"
    fi
    log="$out_base.log"
    out="$out_base.out"
    ## DEBUG: trace-vars _PSL_ out_base log
    local python_arg="-"
    # shellcheck disable=SC2086
    {
	if [ "${USE_STDIN:-0}" == "1" ]; then
	    # note: assumes python script uses - to indicate stdin as per norm for mezcla
	    ## TODO2:
            echo "${script_args[*]}" | DEBUG_LEVEL=$python_debug_level $PYTHON $module_spec "$script_path" $python_arg > "$out" 2> "$log"
	else
	    # note: disables - with explicit arguments or if running pytest
	    if [[ ("${script_args[*]}" != "") || ($PYTHON =~ pytest) ]]; then python_arg=""; fi
            if [ "${USE_STDOUT:-1}" == "1" ]; then
	        DEBUG_LEVEL=$python_debug_level $PYTHON $module_spec "$script_path" "${script_args[@]}" $python_arg > "$out" 2> "$log"
            else
                # TODO3: extend to handle special case with USE_STDIN
	        DEBUG_LEVEL=$python_debug_level $PYTHON $module_spec "$script_path" "${script_args[@]}" $python_arg > "$log" 2>&1
                touch "$out"
            fi
	fi
    }
    # Finalize code profiling
    if [ "$PROFILE_SCRIPT" == "1" ]; then
       alias-python -m mezcla.format_profile "$out_base.data" > "$out_base.list"
    fi
    # Show output and sample of errors, along with file size info
    tail "$log" "$out" | truncate-width
    check-errors-excerpt "$log" "$out"
    ## TEMP: remove emtpy output file (TODO3: streamline -e/-s tests below)
    if [ "$DEBUG_LEVEL" -ge 4 ]; then
        ls -lt "$log" "$out"
    fi
    # note: omitting empty-output pruning useful for background job (e.g., "run-python-script ... &")
    if [ "${KEEP_EMPTY_OUT:-0}" == "0" ]; then
        if [[ (-e "$out") && (! -s "$out") ]]; then
            command rm -v "$out"
        fi
    fi
    ## OLD:
    ## # Show common errors in log
    ## check-errors-excerpt "$log"
}
# run-python-script-reset(): reset variables used in run-python-script
function run-python-script-reset {
    declare -g _PSL_
    _PSL_=0
}

# pytest stuff
default_pytest_opts="-vv --capture=tee-sys"
#
# test-python-script(test-script): run TEST-SCRIPT via pytest
function test-python-script {
    if [ "$1" = "" ]; then
        echo "Usage: [PYTEST_OPTS=[\"$default_pytest_opts\"]] [PYTEST_DEBUG_LEVEL=N] [PYTEST=path] test-python-script script"
        echo "Note: When debugging you might need to use --runxfail and -s to see full error info."
        echo "The debugging level defaults to 5 (unlike run-python-script)."
        return
    fi
    # Extract test script
    local test_script="$1"
    shift
    # note: specifying "tests" for script handled indirectly;
    # this also handles cases like "tests/misc_tests.py" without associated module.
    if [ -e "tests/test_$test_script" ]; then
        test_script="tests/test_$test_script"
    elif [ -e "$test_script" ]; then
        true;
    else
        echo "Warning: cannnot resolve test for _$test_script" 1>&2
    fi
    local pytest_opts="${PYTEST_OPTS:-"$default_pytest_opts"}"
    # TODO3: drop inheritance spec in summary
    # ex: "tests/test_convert_emoticons.py::TestIt::test_over_script <- mezcla/unittest_wrapper.py XPASS" => "tests/test_convert_emoticons.py::TestIt::test_over_script XPASS"
    PYTHON_DEBUG_LEVEL="${PYTEST_DEBUG_LEVEL:-5}" PYTHONUNBUFFERED=1 PYTHON="$PYTEST $pytest_opts" run-python-script "$test_script" "$@" 2>&1;
}
#
# test-python-script-method(test-name, ...): like test-python-script but for specific test
function test-python-script-method {
    local method="$1";
    shift;
    PYTEST_OPTS="-k $method $default_pytest_opts" test-python-script "$@";
}
#
# test-python-script-strict(test-script): run TEST-SCRIPT via pytest with xfail ignored
function test-python-script-strict {
    PYTEST_OPTS="--runxfail $default_pytest_opts" test-python-script "$@";
}
#
# test-python-script-method-strict: likewise for just a method
function test-python-script-method-strict {
    ## TODO2: default_pytest_opts="--runxfail" test-python-script-method "$@";
    local method="$1";
    shift;
    PYTEST_OPTS="--runxfail -k $method $default_pytest_opts" test-python-script "$@";
}

# disable-python-warnings(): Ignore warning due to Pydantic quirks
## TODO:PYTHONWARNINGS="ignore:::pydantic"
# Note: Format is PYTHONWARNINGS="action:message:category:module:lineno";
# but, have to use the Sledge hammer approach due to Pydantic module organization.
function disable-python-warnings {
    ## OLD: export PYTHONWARNINGS="ignore::UserWarning"
    ## TODO: export PYTHONWARNINGS="ignore::UserWarning,ignore::LangChainDeprecationWarning"
    ## NOTE: maldito langchain makes life difficult
    ##    isinstance(LangChainDeprecationWarning, UserWarning) => False
    export PYTHONWARNINGS="ignore"
}
 
# pip-freeze(): save pip freeze in _pip-freeze-{env_spec}-ddMMMyy.log
## note: the ghost of python 2 lives on [WTH?!]
function pip-freeze {
    # TODO2: rework via cmd-output
    local env_spec=""
    local env_name
    # ex: /Users/eafqe/python/.venv-nlp-py-12/bin/python => venv-nlp-py-12
    env_name="$(which python3 | extract-matches "([^\.\/]+)\/bin\/python")"
    if [ "$env_name" != "" ]; then
        env_spec="-$env_name"
    fi
    local freeze_file
    freeze_file="_pip-freeze${env_spec}-$(T).log"
    rename-with-file-date "$freeze_file"
    pip3 freeze > "$freeze_file"
    echo "$freeze_file"
}

# venv-activate([dir=venv]): activate VENV and add python to xterm
function venv-activate {
    local dir="${1:-venv}"
    source "$dir/bin/activate"
    add-conda-env-to-xterm-title
    which python3
    python3 --version
}

#-------------------------------------------------------------------------------
# Jupyter notebook stuff
 
# export-notebook(file, out): export file[.ipynb] to OUT (or $TMP/_file[.py])
# With env. PRETTY=1, the result is pretty printed for readability
function export-notebook {
    local notebook="$1"
    local out_path="$2"
    local pretty="${PRETTY:-0}"
    local relative="${RELATIVE:-0}"
    local tmp="${TMP:-/tmp}"
    if [ "$relative" == "1" ]; then
        # use temp subdir based on notebook dir (e.g., /tmp/notebooks/indexing/pim)
        tmp="$TMP/$(dirname "$notebook")"
    fi
    mkdir -p "$tmp"
    if [ "$out_path" == "" ]; then
        # put exported script in temp dir
        out_path="$tmp/$(basename "$notebook" .ipynb).py";
    fi
    rename-with-file-date "$out_path" "$out_path".pylint
    jupyter nbconvert "$notebook" --to script --stdout > "$out_path"
    if [[ "${RUN_PYLINT:-0}" == "1" ]]; then
        python-lint "$out_path" > "$out_path".pylint
        $EGREP -v 'get_ipython|missing-module-docstring' "$out_path".pylint
    fi
 
    # Account for indentation
    perl -i.bak -0777 -pe 's/\n\n( +)/\n$1#\n$1/g;' "$out_path"
   
    # Pretty print
    if [ "$pretty" != "0" ]; then
        # Make sure run_cell_magic are split across lines for sake of diff
        # ex: "get_ipython().run_cell_magic('time', 'x += 1\ny += 2\n'...)" => "... 'x += 1\n" \\<newline>\ny += 2\n \\<newline>'...)"
        ## BAD: perl -i.bak -pe 's/(run_cell_magic.*)[^\\]\n/\1\\\n \\/g;' "$out_path"
        perl -i.bak -pe 'while (/^get_ipython.*\\n/) { s/^(get_ipython.*)\\n/\1 \\\\\n/g; }' "$out_path"
    fi

    # Make read-only and show line count, etc.
    chmod -w "$out_path"
    wc "$out_path"
}
function export-notebook-temp { TMP=_temp export-notebook "$@"; }
 
 
# run-notebook(jupyter-notebook): runs notebook in batch mode. The script is exported
# to $TMP/basename.py and the output.log is placed in ./basename.out/.log.
#
IPYTHON_TMP="$TMP/ipython"
IPYTHON=(command ipython --no-confirm-exit --simple-prompt --ipython-dir="$IPYTHON_TMP")
#
function run-notebook {
    local file="$1"
    local base
    base="$(basename "$file" .ipynb)"
    rename-with-file-date "$TMP/$base.py" "$base".{out,log}
    export-notebook "$file"
    ## OLD: rename-with-file-date "$base"*
    ("${IPYTHON[@]}" "$TMP/$base.py" | ansifilter) > "$base.out" 2> "$base.log"
    check-errors-excerpt "$base.log"
    head "$base.out" "$base.log"
}
 
 
# export-all-notebooks([dir=.], [temp_dir=_temp]): convert all Jupyter notebooks under DIR into Python script under TEMP_DIR
function export-all-notebooks {
    local dir="${1:-.}"
    local temp="${2:-_temp}"
    mkdir -p "$temp";
    for f in "$dir"/*.ipynb; do
        TMP="$temp" export-notebook "$f";
    done
}
 
# compare-exported-notebooks(notebook): compares Python export of current notebook vs. last one saved
function compare-exported-notebooks {
    local file="$1"
    local base
    if [[ ! ("$file" =~ .ipynb) ]]; then
        echo "usage: compare-exported-notebooks notebook.ipynb"
        echo "note:"
        echo "- Exports notebook to python and compares against most recent"
        echo "- Use compare-notebook-scripts to compare .py version"
        return
    fi
    base="$(basename "$file" .ipynb)"
    ## OLD: local python_path="_temp/$base.py"
    local temp_dir
    temp_dir="$(dirname "$base.py")/_temp"
    mkdir -p "$temp_dir"
    local python_path="$temp_dir/$base.py"
    PRETTY=1 export-notebook "$1" "$python_path"
    local last
    # note: old version gets timstamp added (e.g., my_notebook.py.08Apr24
    # shellcheck disable=SC2010
    last="$(ls -t "$python_path".* | grep -v .bak | head -1)"
    compare-notebook-scripts --ignore '^# In.*:' "$last" "$python_path"
}
 
# compare-notebook-scripts(export1, export2): Compares EXPORT1 and EXPORT2 of Noteboooks
# passes arguments to compare-log-output.sh (q.v.)
function compare-notebook-scripts {
    compare-log-output.sh --ignore '^# In.*:' "$@"
}
 
# run-jupyter-notebook-pristine(port): invoke jupter notenook w/o startup config
## OLD: alias run-jupyter-notebook-pristine='DEBUG_LEVEL=2 IPYTHONDIR="$TMP/ipython" run-jupyter-notebook'
alias run-jupyter-notebook-pristine='DEBUG_LEVEL=2 IPYTHONDIR="$IPYTHON_TMP" run-jupyter-notebook'
 
 

#...............................................................................
# Python utiities

# color-test-failures(): show color-coded test result for pytest run (yellow for xfailed and red for regular fail)
# color-test-results: likewise with green for passed and faint green xpassed
simple-alias-fn color-output 'colout --case-insensitive'
function color-test-failures {
    cat "$@" | color-output "\b(failed|error)" red | color-output "(xfaile?d?)" yellow;
}
function color-test-results {
    cat "$@" | color-output "\b(failed|error)" red | color-output "(xfaile?d?)" yellow | color-output "\bpassed" green | color-output "xpassed" green faint;
}

# ocr-image(image-filename): run image through optical character recognition (OCD)
# shellcheck disable=SC2016
{
    alias-fn ocr-image-stdout 'tesseract "$@" -'
    alias-fn ocr-image 'tesseract "$1" "$1"; $PAGER "$1".txt'
}

#...............................................................................
# Misc. stuff (e.g., JSON, Yaml)
# 

# json-validate(file): make sure file is valid JSON
function json-validate () {
    local file="$1"
    alias-python -c "import json; from mezcla import system; print(json.loads(system.read_file('$file')))" | head -5 | truncate-width
}

# yaml-validate(file): make suire file is valid YAML
function yaml-validate () {
    local file="$1"
    alias-python -c "from mezcla import file_utils; print(file_utils.read_yaml('$file'))" | head -5 | truncate-width
}

# action-lint-yaml: run Github actions yaml file through actionlint
alias action-lint-yaml='actionlint'

# script-config: open dated typescript under ~/config
function script-config {
    mkdir -p ~/config
    script ~/config/"_config-$(T).log"
}
simple-alias-fn act-plain 'convert-emoticons-aux act'

# para-len-alt(file, ...): show length of each paragraph with embedded newlines replaced with CR's to allow chaining
# note: strips the 0-len paragraph indicator
function para-len-alt { perl -00 -pe 's/\n(.)/\r$1/g;' "$@" | line-len | perl -pe 's/^0\t//;'; }

# extract-text-html(filename): extract text from HTML in FILENAME
# shellcheck disable=SC2016
simple-alias-fn extract-text-html 'alias-python -m mezcla.html_utils --regular'

# MS Office conversions
function excel-to-csv {
    local file="$1"
    local base;
    base="$(remove-extension "$file")";
    python -c "import pandas as pd; df = pd.read_excel('$file', dtype=str); df.to_csv('$base.csv', index=False, encoding='utf-8-sig');";
}
 
# Github/ssh stuff
# ssh-cache: activate ssh agent and add user's private key
function ssh-cache {
    # note: ignores SC2046 (warning): Quote this to prevent word splitting
    # shellcheck disable=2046
    eval $(ssh-agent)
    ## OLD: ssh-add "$HOME/.ssh/id_$USER"
    local one_month=$((60 * 60 * 24 * 31))
    ssh-add -t "$one_month" "$HOME/.ssh/id_$USER"
}
alias ssh-access=ssh-cache
 
alias consolidate-notes-here="consolidate-notes.bash --"
 
# copy-relative(path, dir): copy file at PATH to DIR/PATH
function copy-relative {
    local path="$1";
    local dir="$2";
    copy "$path" "$dir/$path";
}

#...............................................................................
# Bash stuff

# bashrc(): [re-]source .bashrc
alias bashrc='source ~/.bashrc'

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
    shell-check -
    # shellcheck disable=SC2181
    [[ $? -eq 0 ]] && echo "shellcheck OK"
}
#
# shell-check-loose(): run shellcheck with relaxed rules
simple-alias-fn shell-check-loose 'shellcheck --exclude="SC2046,SC2086"'

# tabify(text): convert spaces in TEXT to tabs
# TODO: account for quotes
function tabify {
    perl -pe 's/ /\t/g;'
}
# trace-vars(var, ...): trace each VAR in command line
# note: output format: VAR1=VAL1; ... VARn=VALn;
# TODO2: fix bug with trailing whitespace being ignored
function trace-vars {
    local var
    for var in "$@"; do
        ## TODO3: get old eval/echo approach to work in general
        ## # shellcheck disable=SC2027,SC2046
        ## echo -n "$var="$(eval echo "\$$var")"; "
        ## TODO: value="$(eval "echo \$$var")"
        ## NOTE: See https://stackoverflow.com/questions/11065077/the-eval-command-in-bash-and-its-typical-uses
        echo -n "$var=$(eval echo "\${$var}"); "
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
        echo -n "$var=("$(eval echo "\${$var[@]}")"); "
    done
    echo
}

# remote-prompt([prompt="_nickname[0]", suffix-"@']): set prompt to _N@ where N is first letter of host nickname
# note: uses SUFFIX for @ id specified
function remote-prompt {
    local prompt="$1"
    local suffix="${2:-"@"}"
    if [ "$prompt" = "" ]; then prompt="_$(echo "$HOST_NICKNAME" | perl -pe 's/^(.).*/$1/;')$suffix"; fi
    reset-prompt "$prompt"
}
alias-fn remote-prompt-root 'remote-prompt "" "#"'
# TODO2: put alias aliases in separate file to minimize clutter (e.g., to be enabled upon temorary memory lapse)
alias root-prompt-remote=remote-prompt-root
#
# reset-prompt-label(label): reset part of prompt prior to $, #, etc. with text
# For example, if PS_symbol is 'clone $' and label "alt-clone", the result would
# set PS_symbol to 'alt-clone $'
# note: Issues warning if $PS_symbol not set to avoid messing with PS1, etc.
function reset-prompt-label {
    local label="$1"
    ## OLD: local old_label=""
    local old_symbol="$"
    declare -g PS_symbol                # global declaration
    if [ "$PS_symbol" == "" ]; then
        echo "Warning: reset-prompt-label assumes PS_symbol usage" 1>&2
    fi
    ## TODO2: if [[ $PS_symbol =~ ^[\w\s+][\W+]$ ]]; then
    if [[ $PS_symbol =~ [^A-Za-z0-9\ _-]$ ]]; then
        # TODO3: avoid duplication of regex
        # NOTE: ideally should be like @vals = $(get_matches(regex))
        ## OLD: old_label=$(echo "$PS_symbol" | perl -pe 's/^([\w\s]+)(.*\W)$/$1/;')
        old_symbol=$(echo "$PS_symbol" | perl -pe 's/^([\w\s]+)(.*\W)$/$2/;')
        ## OLD: trace-vars old_old_label old_symbol
        ## DEBUG: trace-vars old_symbol
    else
        echo "FYI: PS_symbol w/o trailing symbol: '$PS_symbol'" 1>&2
    fi
    reset-prompt "$label $old_symbol"
}
# reset-prompt-label-here(): sets prompt label to dir basename with existing PS_symbol proper (e.g., "alt $" => "bin $")
# shellcheck disable=SC2016
alias-fn reset-prompt-label-here 'reset-prompt-label "$(basename $PWD)"'

# pristine-bash(): invoke Bash with fresh environment, with prompt to 'pristine $' as a reminder
function pristine-bash {
    env --ignore-environment PS1='pristine $ ' bash --noprofile --norc
}

# indent-text([filename]): indent text in input by 4 spaces
# echo "some text" | indent-text => "    some text"
function indent-text {
    perl -pe "s/^/    /;" "$@";
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

    # Optionally preview result
    # TODO3: add getenv_value helper a la mezcla that gets env. value as well as
    # sets a description.
    if [ "${RENAME_SNAPSHOT_PREVIEW:-0}" = "1" ]; then
        pause-for-enter "About to preview $new_name"
        # TODO2: just preview for a few seconda
        start "$new_name"
    fi
}

#................................................................................
# Media related
#
# fix-transcript-timestamp(file): put text on same line in YouTube transcripts in FILE
alias-fn fix-transcript-timestamp 'perl -i.bak -pe "s/(:\d\d)\n/\1\t/;" "$@"'
# youtube-transcript(url, file): download YoutTube transcript at URL to FILE
function youtube-transcript {
    if [[ ("$2" == "") || ("$1" == "--help") ]]; then
        echo "Usage: youtube-transcript url file" 1>&2
        echo "" 1>&2
        echo "Note: More details follow:"  1>&2
        echo "" 1>&2
        ## TODO3: add alias for showing condensed mezcla script usage notes
        alias-python -m mezcla.examples.youtube_transcript --help 2>&1 | perl -0777 -pe 's/positional arguments[^\xFF]*//;' 1>&2
        return
    fi
    local url="$1"
    local file="$2"
    alias-python -m mezcla.examples.youtube_transcript "$url" > "$file"
}
# youtube-transcript-alt(): workaround for silly bash problem:
#    $ youtube-transcript 'https://www.youtube.com/watch?v=gcgMyRfE8a4&t=247s'
#    bash: : No such file or directory
# This also allows for stdout instead of requiring a file.
# TODO: check for &'s in URL and issue warning
# DUH: The "$file" redirection was causing problems (Thanks, Grok!)
# TODO2: check for other aliases with similar issues
function youtube-transcript-alt {
    local url="$1"
    local file="$2"
    if [[ ("$file" == "") || ("$1" == "--help") ]]; then
        echo "Usage: youtube-transcript-alt url [file | -]" 1>&2
        echo "See youtube-transcript --help for details"  1>&2
        return
    fi
    if [[ "$file" == "-" ]]; then
        alias-python "$(which youtube_transcript.py)" "$url"
    else
        alias-python "$(which youtube_transcript.py)" "$url" > "$file"
    fi
}

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
    if [[ ("$dir" == "") || ("$dir" == --help) ]]; then
        ## TODO4: $* =~ --help
        echo "Usage create-zip [dirname]"
        echo "ex: [ENCRYPT=b] [TEMP=d] create-zip /mnt/resmed"
        return
    fi
    local extra_args=()
    if [ "${ENCRYPT:-0}" == "1" ]; then
        extra_args+=("-e")
    fi
    local archive
    archive="${TEMP:-/tmp}/$(basename "$dir").zip"
    echo "issuing: zip -r -u ${extra_args[*]} \"$archive\" \"$dir\""
    # options: -r recursive; -u update
    zip -r -u "${extra_args[@]}" "$archive" "$dir";
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

#...............................................................................
# Linux stuff

# calendar: wrapper for cal using ncal variant (n.b., to ensure highlighting)
# options: -b: old-style formatting
alias calendar="ncal -b"
## HACK (can't find ncal via homebrew):
under-macos 1 && alias calendar="cal"

# Ps-time: show processes by time via ps_sort.perl
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
# sd-style(image): make note that IMAGE has given style
simple-alias-fn sd-note 'todo style: '
simple-alias-fn sd-grotesque 'sd-note grotesque'

# distro-version-info(): show various information related to distribution, including window and display managers
# note: screenfetch sans the ascii art
# distro-version-info-neo(): likewise using newer neofetch
alias distro-version-info='screenfetch -n'
alias distro-version-info-neo='neofetch --off'

# detach-job: disassociate last (GUI) command from terminal (-h is for SIGHUP)
# See https://unix.stackexchange.com/questions/484276/do-disown-h-and-nohup-work-effectively-the-same
alias detach-job='disown -h'

# screenshot-window(): take screen shot of another window in 2 seconds
# TODO3: add option for --screen and for specifying --file
# shellcheck disable=SC2016
simple-alias-fn screenshot-window 'gnome-screenshot --window --delay ${SCREENSHOT_DELAY:-3}'

# show-window-list(): show window title, etc.
alias show-window-list='wmctrl -l'

#...............................................................................
# Linux admin

# free-memory: show available memory
alias free-memory='free --wide --human | grep -v Swap:'
# clear-cache: clear disk cache
# See https://linux-mm.org/Drop_Caches and https://www.linuxatemyram.com
# TODO: get this to work completely; explain Admin filter
simple-alias-fn clear-cache 'echo; date; echo before; free-memory; sync; sysctl vm.drop_caches=3; echo after; free-memory; echo'

#...............................................................................
# Emacs related

# reset-under-emacs: clear settings added for Bash under emacs
# note: for use in external terminal invoked under Emacs term (e.g., via gterm)
function reset-under-emacs {
    unset UNDER_EMACS SCRIPT_PID
    all-tomohara-settings
}
simple-alias-fn emacs-wide-horizontal 'tpo-invoke-emacs.sh -geometry 288x50 -eval "(split-window-right)"'

# df-h(dir=[.], ...): show DIR disk free in human readable format
function df-h {
    ## OLD:
    ## local dirs=("$@")
    ## if [[ "${#dirs[@]}" == 0 ]]; then dirs=(.); fi
    local dirs=("${@:-.}")
    df -h "${dirs[@]}"
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

# Docker
# shellcheck disable=SC2046
function docker-cleanup {
    pause-for-enter "Removing all docker containers, images, etc. (Press Enter to proceed or ^C to abort)"
    # shellcheck disable=SC2046
    {
        docker rm -vf $(docker ps -aq)
        docker rmi -f $(docker images -aq)
        docker system prune --force
    }
}

#................................................................................
# Doubly idiosyncratic stuff (i.e., given "tomohara-proper" part of filename)
# note: although 'kill-it xyz' is not hard to type 'kill-xyz' allows for tab completion
#
alias tomohara-proper-aliases='source "$TOM_BIN/tomohara-proper-aliases.bash"'
alias all-tomohara-aliases='source $TOM_BIN/all-tomohara-aliases-etc.bash'
alias all-tomohara-settings='all-tomohara-aliases; tomohara-settings'
#
# note: kill-em targets process name, and kill-it uses pattern (hence riskier)
alias kill-kdiff3='kill-it kdiff3'
alias kill-firefox='kill-it firefox'
alias kill-jupyter='kill-it python.*jupyter'
alias kill-chromiun='kill-it chromium'
## OLD: alias kill-sleep='kill_em.sh sleep'
alias kill-sleep='kill-em sleep'
alias kill-hp='kill-it hp-systray'
