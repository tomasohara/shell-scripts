#! /bin/bash
#
# Aliases for Git source control (see https://git-scm.com).
#
# Usage example(s):
#   source git-aliases.bash
#
#   git-update                       ## git-pull with stashed changes
#
#   git-commit-and-push file, ...
#
#   git-update-commit-push $(git diff 2>&1 | extract_matches.perl "^diff.*b/(.*)")
#
#...............................................................................
# Notes:
#
# - credentials can be taken from project specific file (_my-git-credentials-etc.bash:.list)
#
#     git_user=username
#     git_token=personal_access_token
#
# - alternatively git caching is used via
#     ~/.git-credentials
#   See https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage.
#
# - config needed for using stored credentials (~/.gitconfig):
#
#   [credential]
#   helper = store
#
# - To squalsh shellcheck warning and to help against inadvertant changes,
#   declarations are separate from assignment involving commands. For example,
#      local log=$(get-temp-log-name "update")
#      =>
#      local log
#      log=$(get-temp-log-name "update")
#   See https://unix.stackexchange.com/questions/506352/bash-what-does-masking-return-values-mean. Of course, shellcheck should be refined to check for $?, but
#   that might take a while.
#
#................................................................................
# Examples:
# - Update
#     git stash;  git pull --all;  git stash pop
# - Commit changes
#     git add tomohara-aliases.bash;  git commit -m "reconciliation";  git push
# - Delete merge state (to allow update)
#     git reset --hard HEAD
#...............................................................................
# via https://stackoverflow.com/questions/10169328/git-your-branch-is-ahead-of-origin-master-by-1-commit:
#
# The order of operations is:
#
# [0. Make your change.]
# 1. git add - this stages your changes for committing
# 2. git commit - this commits your staged changes locally
# 3. git push - this pushes your committed changes to a remote
#

# pause-for-enter(): print message and wait for user to press enter
# TODO: extend to press-any-key; see
#    https://unix.stackexchange.com/questions/293940/how-can-i-make-press-any-key-to-continue
function pause-for-enter () {
    local message="$1"
    if [ "$message" = "" ]; then message="Press enter to continue"; fi
    read -p "$message "
}

# downcase-stdin: return stdin made lowercase
# note: only will be defined here if tomohara-aliases not sourced
if [ "" = "$(typeset -f downcase-stdin)" ]; then
    function downcase-stdin () 
    { 
	perl -pe "use open ':std', ':encoding(UTF-8)'; s/.*/\L$&/;"
    }
fi

# get-temp-log-name([label=temp]: Return unique file name of the form _git-LABEL-MMDDYY-HHMM-NNN.log
function get-temp-log-name {
    local label=${1:-temp}
    local now_mmddyyhhmm
    now_mmddyyhhmm=$(date '+%d%b%y-%H%M' | downcase-stdin);
    # TODO: use integral suffix (not hex)
    mktemp "_git-$label-${now_mmddyyhhmm}-XXX.log"
}

# git-update(): updates local from global repo. This uses git-stash to hide local changes
# does a git-pull, and then restores local changes.)
function git-update {
    local log
    log=$(get-temp-log-name "update")
    echo "issuing: git stash"
    git stash >> "$log"
    echo "issuing: git pull --all"
    git pull --all >> "$log"
    echo "issuing: git stash pop"
    git stash pop >> "$log"
    echo >> "$log"
    tail "$log"
}

# git-commit-and-push(file, ...): commits FILE... to local repo, which is then
# pushed to global repo
# note: gets user credentials from ./_my-git-credentials-etc.bash.list
# TODO: add message argument
function git-commit-and-push {
    local log
    log=$(get-temp-log-name "commit")
    local git_user
    local git_token
    local credentials_file="_my-git-credentials-etc.bash.list"
    local dir
    # Note: check stored credentials
    if [[ -e ~/.git-credentials ]]; then
        echo "Using git credentials via ~/.git-credentials"
    fi
    for dir in . ~; do
	if [[ ($git_user = "") && (-e "$dir/$credentials_file") ]]; then
            echo "Sourcing credentials ($dir/$credentials_file)"
            source "$dir/$credentials_file"
	    break
	fi
    done
    echo "git_user: $git_user;  git_token: $git_token"
    echo "issuing: git add \"$*\""
    git add "$@" >> "$log"
    # TODO: rework so that message passed as argument (to avoid stale messages from environment)
    local message="$GIT_MESSAGE";
    if [ "$message" = "..." ]; then
        echo "Error: '...' not allowed for commit message (to avoid cut-n-paste error)"
        return
    fi
    if [ "$message" = "" ]; then
        echo "Error: '' not allowed for commit message (to avoid [G]IT_MESSAGE error)"
        return
    fi

    # Push the changes after showing synopsis and getting user confirmation
    local file_spec="$*"
    echo ""
    pause-for-enter "About to commit $file_spec (with message '$message')"
    git commit -m "$message" >> "$log"
    # TODO: perl -e "print("$git_user\n$git_token\n");' | git push
    # TODO: see why only intermittently works (e.g., often prompts for user name and password)
    perl -pe 's/^/    /;' "$log"
    pause-for-enter 'About to push: review commit log above!'
    #
    echo "issuing: git push --verbose"
    git push --verbose <<EOF >> "$log"
$git_user
$git_token
EOF
    echo >> "$log"
    tail "$log"
}


# git-update-commit-push(file, ...): updates local repo and then commits FILE... to global repo
# note: gets user credentials from ./.my-git-settings.bash
# TODO: skip commit if problem with update
function git-update-commit-push {
    # DEBUG: set -o xtrace
    git-update
    git-commit-and-push "$@"
    # DEBUG: set - -o xtrace
}
#
# git-update-commit-push-all(): adds all files for checkin
alias git-update-commit-push-all='git-update-commit-push *'


function git-pull-and-update() {
    if [ "" = "$(grep ^repo ~/.gitrc)" ]; then echo "*** Warning: fix ~/.gitrc for read-only access ***"; else
        local git="python -u /usr/bin/git";
        local log
	log=$(get-temp-log-name "update")
        ## OLD: ($git pull --noninteractive --verbose;  $git update --noninteractive --verbose) >> "$log" 2>&1; less "$log"
	echo "issuing: $git --noninteractive --verbose"
        $git pull --noninteractive --verbose >> "$log" 2>&1
	echo "issuing: $git update --noninteractive --verbose"
        $git update --noninteractive --verbose >> "$log" 2>&1; 
        less "$log"
    fi;
}

# run git COMMAND with output saved to command-specific temp file
#
function invoke-git-command {
    local command="$1"
    shift
    ## OLD: local log="_git-$command-$(TODAY).$$.log";   ## OLD: log="_git-$command-$(TODAY).$$.log";
    local log
    log=$(get-temp-log-name "$command")
    echo "issuing: git $command \"$*\""
    git "$command" "$@" >| "$log" 2>&1
    less "$log"
}
alias git-command='invoke-git-command'

function git-push() {
    if [ "" != "$(grep ^repo ~/.gitrc)" ]; then
	echo "*** Warning: fix ~/.gitrc for read-write access ***";
    else
	invoke-git-command push --verbose "$@"
    fi;
}

# Misc git commands (redirected to log file)
alias git-status='invoke-git-command status'
# TODO: git-log => git-log-changes
alias git-log='invoke-git-command log --name-status'
alias git-log-diff='invoke-git-command log --patch'

# git-add: add filename(s) to repository
function git-add {
    local log
    log=$(get-temp-log-name "add")
    git add "$@" >| "$log";
    less "$log";
}

# git-diff: show repo diff
function git-diff {
    local log
    log=$(get-temp-log-name "diff")
    git diff "$@" >| "$log";
    less -p '^diff' "$log";
}
#
## OLD: alias git-difftool='git difftool --no-prompt'
function git-difftool {
    echo "issuing: git difftool --no-prompt"
    git difftool --no-prompt
}
#
function git-vdiff { git-difftool "$@" & }

# Produce listing of changed files
# note: used in check-in templates, so level of indirection involved
#
function git-diff-list-template {
    echo "diff_list_file=\$TMP/_git-diff.\$\$.list"
    echo "git diff 2>&1 | extract_matches.perl '^diff.*b/(.*)' >| \$diff_list_file"
}
function git-diff-list {
    local diff_list_file
    local diff_list_script="$TMP/_git-diff-list.$$.bash"
    git-diff-list-template >| "$diff_list_script"
    source "$diff_list_script"
    cat "$diff_list_file"
}

# Output templates for doing checkin of modified files
function git-checkin-template-aux {
    git-diff-list-template
}
#
function git-checkin-single-template {
    git-checkin-template-aux
    echo "# To check in one file (ideally with main differences noted):"
    echo "mod_file=\$(head -1 < \"\$diff_list_file\"); git-vdiff \"\$mod_file\""
    echo "echo GIT_MESSAGE=\\\"...\\\" git-update-commit-push \"\$mod_file\""
}
#    
function git-checkin-multiple-template {
    git-checkin-template-aux
    echo "# To generate template from above diff for individual check-in's:"
    echo "cat \$diff_list_file | xargs -I \"{}\" echo GIT_MESSAGE=\\\"...\\\" git-update-commit-push \"{}\""
}
#
function git-checkin-all-template {
    git-checkin-template-aux
    echo "# To do shamelessly lazy check-in of all modified files:"
    echo "echo GIT_MESSAGE=\'...\' git-update-commit-push \$(cat \$diff_list_file)"
}

# invoke-next-single-checkin: outputs and runs the next single-checking template
function invoke-next-single-checkin {
    git-checkin-single-template >| "$TMP/_template.sh"
    source "$TMP/_template.sh"
}
#
# alt-invoke-next-single-checkin([filename]) alternative version that uses readline
# with template text for checking in next change (or FILENAME if given)
# NOTE: although potentially dangerous given eval environnment, the user still needs to
# confirm the commit operation (and thus can verify done OK).
function alt-invoke-next-single-checkin {
    # If unspecified, determine file to check in, based on next modified file
    local mod_file="$1"
    if [ "$mod_file" = "" ]; then
	mod_file=$(git-diff-list | head -1);
	if [ "$mod_file" = "" ]; then
	    echo "Warning: unable to infer modified file. Perhaps,"
            echo "    Tha-tha-that's all folks"'!'
	    return;
	fi
    fi

    # Read the user's commit message
    # note: shows visual diff (TODO: and pauses so user can start message)
    # TODO: position cursor at start of ... (instead of pause)
    local is_text
    ## TODO: fix problem identifing scripts with UTF-8 as text (e.g., common.perl reported as data by file command)
    is_text=$(file "$mod_file" | grep -i ':.*text')
    if [ "$is_text" != "" ]; then
	git-vdiff "$mod_file"
    else
        ## TODO: summarize binary differenecs
	git diff --numstat "$mod_file" | head
        true
    fi
    ## BAD: sleep 3
    local prompt="GIT_MESSAGE=\"...\" git-update-commit-push \"$mod_file\""
    local command
    echo "TODO: modify the GIT_MESSAGE (escaping $'s, etc.) and verify read OK in commit confirmation."
    read -e -i "$prompt" command

    # Evaluate the user's checkin command
    # TODO: rework using a safer approach with reading checking comment and issuing git-update-commit-push directly
    ## DEBUG:
    ## echo "Running (n,b, *** be careful nothing lost ***):"
    ## echo "   $command"
    eval "$command"
}
#
# invoke-alt-checkin(filename): run alternative template-bsed checkin for filename
function invoke-alt-checkin { alt-invoke-next-single-checkin "$1"; }

# git-alias-usage: tips on interactive usage
function git-alias-usage () {
    echo "Usage examples for git aliases, most of which create log files as follows:"
    echo "   _git-CMD-MMDDYY-HHMM-NNN.log      # ex: _git-status-07mar22.339.log"
    echo ""
    # note: 'clear's -x option doesn't clobber (to work around a disruptive change that feel through effing cracks!)'
    echo "To update aliases:"
    echo "   source \$TOM_BIN/git-aliases.bash; clear -x; git-alias-usage"
    echo ""
    echo "Get changes from repository:"
    echo "    git-update"
    echo ""
    echo "To add files (implicit git-add):"
    echo "    GIT_MESSAGE='initial version' git-update-commit-push file ..."
    echo ""
    echo "To check in specified changes:"
    echo "    GIT_MESSAGE='...' git-update-commit-push file ..."
    echo ""
    #
    # Note: disable spurious spellcheck SC2016 (n.b., unfortunately just for next statement, so awkward brace group added)
    #    Expressions don't expand in single quotes, use double quotes for that.
    # shellcheck disable=SC2016
    {
        echo "To check in files different from repo:"
	echo "    git-checkin-single-template >| \$TMP/_template.sh; source \$TMP/_template.sh"
	# TODO: echo '    git-checkin-single-template | source'
	echo '    # ALT: git-checkin-multiple-template and git-checkin-all-template (n.b. ¡cuidado!)'
	echo '    alt-invoke-next-single-checkin'
	local next_mod_file
	next_mod_file=$(git-diff-list | head -1)
	if [ "$next_mod_file" = "" ]; then next_mod_file="TODO:filename"; fi
	echo '    invoke-alt-checkin "'${next_mod_file}'"'
	echo '    git-cd-root'
	echo '    invoke-alt-checkin'
    }
}

# Various aliases
## TODO: include suffix to better differentiate from regular git-xyz commands
alias git-template=git-alias-usage
alias git-root='git rev-parse --show-toplevel'
alias git-cd-root='cd $(git-root)'
alias git-invoke-next-single-checkin=invoke-next-single-checkin
alias git-alias-refresh="source ${BASH_SOURCE[0]}"

