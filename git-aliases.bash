#! /bin/bash
#
# Aliases for Git source control (see https://git-scm.com).
#
# TODO: if interactive, warn that only intended for non-interactive use
#
# usage:
# $ source git-aliases.sh
#
#...............................................................................
# Notes:
#
# via https://gist.github.com/flc/f867e2b92cc878a55801#file-hg_vs_git-txt:
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
    git stash >> $log
    git pull --all >> $log
    git stash pop >> $log
    echo >> $log
    tail $log
}

# git-commit(file, ...): commits FILE... to global repo
# note: gets user credentials from ./.my-git-settings.bash
# TODO: add message argument
function git-commit {
    local log="_git-commit-$(TODAY).log"
    local git_user
    local git_token
    source ./my-git-settings.bash
    git add "$@" >> $log
    git commit -m "misc. update" >> $log
    # TODO: perl -e "print("$git_user\n$git_token\n");' | git push
    git push <<EOF >> $log
$git_user
$git_token
EOF
    echo >> $log
    tail $log
}


# git-safe-commit(file, ...): updates local repo and then commits FILE... to global repo
# note: gets user credentials from ./.my-git-settings.bash
# TODO: skip commit if problem with update
function git-safe-commit {
    git-update
    git-commit "$@"
}

function git-pull-and-update() {
    if [ "" = "$(grep ^repo ~/.gitrc)" ]; then echo "*** Warning: fix ~/.gitrc for read-only access ***"; else
        git="python -u /usr/bin/git"; log_file=_git-update-$(date '+%d%b%y').log; ($git pull --noninteractive --verbose; $git update --noninteractive --verbose) >| $log_file 2>&1; less $log_file
    fi;
}

function git-push() {
    if [ "" != "$(grep ^repo ~/.gitrc)" ]; then echo "*** Warning: fix ~/.gitrc for read-write access ***"; else 
	git push --verbose
    fi;
}

function git-diff () { git diff "$@" 2>&1 | less -p '^diff'; }

