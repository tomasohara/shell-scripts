#! /bin/bash
#
# Aliases for Git source control (see https://git-scm.com).
#
# TODO: if interactive, warn that only intended for non-interactive use
#
# Usage example(s):
#   source git-aliases.bash
#
#   git-update
#
#   git-safe-commit $(git diff 2>&1 | extract_matches.perl "^diff.*b/(.*)")
#
#   git-unsafe-commit
#    
#...............................................................................
# Notes:
#
# - credentials taken from my-git-credentials-etc.bash:
#
#   git_user=username
#   git_token=personal_access_token
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

# git-update(): updates local to global repo
function git-update {
    local log="_git-update-$(TODAY).log"
    git stash >> "$log"
    git pull --all >> "$log"
    git stash pop >> "$log"
    echo >> "$log"
    tail "$log"
}

# git-commit(file, ...): commits FILE... to global repo
# note: gets user credentials from ./.my-git-settings.bash
# TODO: add message argument
function git-commit {
    local log="_git-commit-$(TODAY).log"
    local git_user
    local git_token
    local credentials_file="./my-git-credentials-etc.bash"
    if [ -e "$credentials_file" ]; then
	# TODO: if [ $verbose ]; then echo ...; fi
	echo "Sourcing $credentials_file"
	source "$credentials_file"
	echo "git_user: $git_user;  git_token: $git_token"
    fi
    git add "$@" >> "$log"
    git commit -m "misc. update" >> "$log"
    # TODO: perl -e "print("$git_user\n$git_token\n");' | git push
    git push --verbose <<EOF >> "$log"
$git_user
$git_token
EOF
    echo >> "$log"
    tail "$log"
}


# git-safe-commit(file, ...): updates local repo and then commits FILE... to global repo
# note: gets user credentials from ./.my-git-settings.bash
# TODO: skip commit if problem with update
function git-safe-commit {
    # DEBUG: set -o xtrace
    git-update
    git-commit "$@"
    # DEBUG: set - -o xtrace
}
#
# git-unsafe-commit(): adds all files for checkin
# TODO: add verification before commit
alias git-unsafe-commit='git-safe-commit *'


function git-pull-and-update() {
    if [ "" = "$(grep ^repo ~/.gitrc)" ]; then echo "*** Warning: fix ~/.gitrc for read-only access ***"; else
        local git="python -u /usr/bin/git";
	local log="_git-update-$(date '+%d%b%y').log";
	($git pull --noninteractive --verbose;  $git update --noninteractive --verbose) >| "$log" 2>&1; less "$log"
    fi;
}


function git-push() {
    if [ "" != "$(grep ^repo ~/.gitrc)" ]; then echo "*** Warning: fix ~/.gitrc for read-write access ***"; else 
	git push --verbose
    fi;
}

function git-diff () {
    git diff "$@" 2>&1 | less -p '^diff';
}


function git-alias-usage () {
    echo "Usage examples for git aliases, all assuming following:"
    echo "   echo 'source git-aliases.bash'"
    echo ""
    echo "Get changes from repository:"
    echo "    git-update"
    echo ""
    echo "To check in specified changes:"
    echo "    git-safe-commit file, ..."
    echo ""
    #
    # Note: disable spellcheck SC2016 (n.b., unfortunately just for next statement, so awkward brace group added)
    #    Expressions don't expand in single quotes, use double quotes for that.
    # shellcheck disable=SC2016
    {
	echo "To check in files different from repo:"
	echo '    #    TODO: pushd $REPO_ROOT'
	echo '    #    -OR-: pushd $(realpath .)/..'
	echo '    log=$TMP/_git-diff.$$.list'
	echo '    git diff 2>&1 | extract_matches.perl "^diff.*b/(.*)" > $log'
	echo '    cat $log'
	echo '    git-safe-commit $(cat $log)'
	echo '    #    TODO: popd'
    }
    #
    echo ""
    echo "To check in all changes:"
    echo "    git-unsafe-commit"
    echo ""
}
