#! /bin/bash
#
# Aliases for Git source control (see https://git-scm.com).
#
# TODO: if interactive, warn that only intended for non-interactive use
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
# - via https://gist.github.com/flc/f867e2b92cc878a55801#file-hg_vs_git-txt:
#
#   hg init => git init
#   hg add <path> => git add <path>
#   hg commit -m 'Commit message' => git commit -m 'Commit message'
#      git add NEW -and/or- OLD; git commit -m <MESSAGE>; git push
#   hg commit => git commit -a
#   hg status => git status -s
#   hg clone <path> => git clone <path>
#   hg branch <branchname> => git checkout -b <branchname> (-b also switch to new branch)
#   hg pull & hg update => git pull --all
#      # TODO: git stash; git pull --all; git stash pop
#   hg diff => git diff HEAD
#   hg rm => git rm
#   hg push => git push
#   hg update <branch> => git checkout <branchname>
#   hg branches => git branch
#   hg revert filename => git checkout filename (This command is also used to checkout branches, and you could happen to have a file with the same name as a branch. All is not lost, you will simply need to type: git checkout -- filename)
#   hg revert => git reset --hard
#   hg log -l 5 => git log -n 5
#   hg merge <branch> => git merge <branch>
#   hg import <diff_file> => git apply <diff_file>
#   
#   set default editor to <editor>:
#   git config --global core.editor <editor>
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

# git-update(): updates local from global repo. This uses git-stash to hide local changes
# does a git-pull, and then restores local changes.)
function git-update {
    local log="_git-update-$(TODAY).$$.log"
    git stash >> "$log"
    git pull --all >> "$log"
    git stash pop >> "$log"
    echo >> "$log"
    tail "$log"
}

# git-commit-and-push(file, ...): commits FILE... to local repo, which is then
# pushed to global repo
# note: gets user credentials from ./_my-git-credentials-etc.bash.list
# TODO: add message argument
function git-commit-and-push {
    local log="_git-commit-and-push-$(TODAY).$$.log"
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
    git add "$@" >> "$log"
    # TODO: rework so that message passed as argument (to avoid stale messages from environment)
    local message="$GIT_MESSAGE";
    if [ "$message" = "..." ]; then
        echo "Error: '...' not allowed for commit message (to avoid cut-n-paste error)"
        return
    fi
    if [ "$message" = "" ]; then message="misc. update"; fi
    local file_spec="$*"
    pause-for-enter "About to commit $file_spec (with message '$message')"
    git commit -m "$message" >> "$log"
    # TODO: perl -e "print("$git_user\n$git_token\n");' | git push
    # TODO: see why only intermittently works (e.g., often prompts for user name and password)
    perl -pe 's/^/    /;' "$log"
    pause-for-enter 'About to push: review commit log above!'
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
        local log="_git-update-$(date '+%d%b%y').$$.log";
        ($git pull --noninteractive --verbose;  $git update --noninteractive --verbose) >> "$log" 2>&1; less "$log"
    fi;
}


function git-push() {
    if [ "" != "$(grep ^repo ~/.gitrc)" ]; then echo "*** Warning: fix ~/.gitrc for read-write access ***"; else 
        git push --verbose
    fi;
}

# git-add: add filename(s) to repository
function git-add {
    local log="_git-diff-$(TODAY).$$.log";
    git add "$@" >| "$log";
    tail "$log";
}

# git-diff: show repo diff
function git-diff {
    ## OLD: git diff "$@" 2>&1 | less -p '^diff';
    local log="_git-diff-$(TODAY).$$.log"
    git diff "$@" >| "$log";
    less -p '^diff' "$log";
}
#
alias git-difftool='git difftool --no-prompt'
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
    echo "echo GIT_MESSAGE=\'miscellaneous update\' git-update-commit-push \$(cat \$diff_list_file)"
}

# git-alias-usage: tips on interactive usage
function git-alias-usage () {
    echo "Usage examples for git aliases, most of which create log files as follows:"
    echo "   _git-{label}-\$(TODAY).\$\$.log      # ex: _git-update-$(TODAY).$$.log"
    echo ""
    echo "To update aliases:"
    echo "   source \$TOM_BIN/git-aliases.bash; clear; git-alias-usage"
    echo ""
    echo "Get changes from repository:"
    echo "    git-update"
    echo ""
    echo "To check in specified changes:"
    echo "    GIT_MESSAGE='...' git-update-commit-push file ..."
    echo ""
    #
    # Note: disable spellcheck SC2016 (n.b., unfortunately just for next statement, so awkward brace group added)
    #    Expressions don't expand in single quotes, use double quotes for that.
    # shellcheck disable=SC2016
    {
        echo "To check in files different from repo:"
	echo "    # TODO: pushd \$REPO_ROOT"
	echo "    # -OR-: pushd \$(realpath .)/.."
	echo '    git-checkin-single-template >| _git-checkin-template.sh; source _git-checkin-template.sh'
	echo '    # ALT: git-checkin-multiple-template and git-checkin-all-template (n.b. ¡cuidado!)'
    }

}
