#! /bin/bash
#
# Aliases for Git source control (see https://git-scm.com). For the most part, these
# composite operations such as git-update-commit-push. In some cases, the aliases are
# a thin wrapper around the git command of the same name, such as creating log files
# named accordingly.
#
# Warning: This script is currently tied too much to my aliases (tomohara-aliases.bash),
# which are currently getting overhauled.
#
# Usage example(s):
#   source git-aliases.bash
#
#   git-template                     # show detailed usage template
#
#   git-update-plus                  # git-pull with stashed changes
#
#   git-commit-and-push file...      # commits file and pushes to remote
#
#...............................................................................
# Notes:
#
# - [Deprecated] Credentials can be taken from project specific file (_my-git-credentials-etc.bash.list)
#
#     git_user=username
#     git_token=personal_access_token
#
#     *** Warning: This is not secure, and should be avoided in multi-user environments. ***
#
# - [New] To use platform-native data stores to control sensitive information:
#   https://github.com/GitCredentialManager/git-credential-manager
#
# - [Old] Alternatively, git caching is used via
#     ~/.git-credentials
#   See https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage.
#
# - Configuration needed for using stored credentials (~/.gitconfig):
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
# - Git updates optionally preserves the timestamps if PRESERVE_GIT_STASH env-var is 1 (TODO: rename to something like PRESERVE_GIT_STASH_TIMESTAMPS):
#   export PRESERVE_GIT_STASH=1
#
# - Most aliases start with git- for sake of tab completion. A suffix is added when there might be confusion.
#
# - Environment options:
#   PRESERVE_GIT_STASH           preserve timestamps of stashed files
#   UNSAFE_GIT_CREDENTIALS       use old-style credentials file
#   -- internal
#      GIT_MESSAGE               message for update (TODO: rework to use optional arg)
#
# - maldito shellcheck:
#   SC2002 [Useless cat. Consider 'cmd < file | ..' or 'cmd file | ..' instead]
#   SC2016 [Expressions don't expand in single, use double]
#   SC2086 [Double quote to prevent globbing and word splitting]
#
# - By the way, "maldito" is Spanish for "damn", which is a mild expletive in English.
#
#................................................................................
# Examples:
# TODO2: show the corresponding alias; also move git-mv example later to this section)
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
#...............................................................................
# based on https://stackoverflow.com/questions/2641146/handling-file-renames-in-git:
#
# 1: rename the file from old-file to new-file
#     git mv old-file new-file
# 1.5 mark old file as changed
#     git add old-file
# 2: commit and add comments
#     git commit -m "renamed old-file to new-file"
# 3: push this change to the remote server
#     git push
#
#................................................................................
# Aliases from tomohara-aliaes.bash:
#-------------------------------------------------------------------------------
# TODO:
# - ** TODO: diagnose problem with git checkin for simple_batspp.py [Fri 15 Jul 22].
# - * Get a git guru to critique (e.g., how to make more standard)!
# - Add an option for verbose tracing (and for quiet mode).
# - Simplify environment-based variable initializations using "${ENV:-default}" approach.
#
# TODO1:
# - Filter miscellaneous output from git command execution (e.g., "enumerating objects"
#   from git-update-commit-push), such as by just showing 'issuing' output.
#
# TODO2:
# - Fix detection of .ipynb files as binary (e.g., via specical case exception).
#

## DEBUG: echo "in ${BASH_SOURCE[0]}"

#................................................................................
# Aliases

# pause-for-enter(): print message and wait for user to press enter
# TODO: extend to press-any-key; see
#    https://unix.stackexchange.com/questions/293940/how-can-i-make-press-any-key-to-continue
function pause-for-enter () {
    local message="$1"
    ## TODO2: add "enter or ^C" to user message
    if [ "$message" = "" ]; then message="Press enter to continue"; fi
    # Maldito shellcheck: SC2162 [read without -r will mangle backslashes].
    # shellcheck disable=SC2162
    if [ "$GIT_NO_CONFIRM" = "1" ]; then
        echo "GIT_NO_CONFIRM set to 1, so skipping confirmation"
    else 
        read -p "$message "
    fi
}

# downcase-stdin-alias: return stdin made lowercase
function downcase-stdin-alias () 
{ 
    perl -pe "use open ':std', ':encoding(UTF-8)'; s/.*/\L$&/;"
}

# quiet-unalias-alias(name): undefines NAME alias w/o error message
# NOTE: used during transition from an alias proper to a function
# TODO: add clear-and-redefine-aliases function elsewhere to address this
function quiet-unalias-alias {
    unalias "$@" 2> /dev/null || true;
}


# HACK: wrapper around check_errors.perl w/ new QUIET option
function get-log-errors () { (QUIET=1 DEBUG_LEVEL=1 check_errors.perl -context=5 "$@") 2>&1; }

#................................................................................

# get-temp-log-name([label=temp]: Return unique file name of the form _git-LABEL-MMDDYY-HHMM-NNN.log
#
#
function get-temp-log-name {
    local label=${1:-temp}
    local now_mmddyyhhmm
    # note: done each time in case user cd's to a different directory
    local LOG_DIR="${GIT_LOG_DIR:-./log-files}"
    mkdir --parents "$LOG_DIR"
    now_mmddyyhhmm=$(date '+%d%b%y-%H%M' | downcase-stdin-alias);
    # TODO: use integral suffix (not hex)
    mktemp "$LOG_DIR/_git-$label-${now_mmddyyhhmm}-XXX.log"
}

# git-alias-review-log(file): review log FILE checking for common errors
# note: returns non-zero status code upon likely error (using heuristics in check_errors.perl)
function git-alias-review-log {
    local status=0
    local log="$1"
    local errors
    errors=$(get-log-errors "$log")
    if [ "$errors" != "" ]; then
        echo "*** Error(s):"
        echo "$errors"
        local status=1
    fi
    tail "$log" | cat | truncate-width;
    return $status
}

# git-update-plus(): updates local from global repo. This uses git-stash to hide local changes
# does a git-pull, and then restores local changes.
# Note:
# - If PRESERVE_GIT_STASH is 1, then timestamps are preserved.
# - If GIT_NO_CONFIRM is 1, pause for enter does not pause
# - Requires GIT_FORCE of 1 if there are changed files (to avoid inadvertant conflict).
# - TODO2: decompose this monster of a function!
function git-update-plus {
    local git_user="n/a"
    local git_token="n/a"
    if [ "$UNSAFE_GIT_CREDENTIALS" = "1" ]; then
       set-global-credentials
       echo "git_user: $git_user;  git_token: $git_token"
    fi
    #
    local log
    log=$(realpath "$(get-temp-log-name 'update')")

    # Optionally preserve timestamps for changed files
    # NOTES:
    # - The stash-pop causes the timestamps to be changed. The workaround to this quirk
    # - backups and restore the modified files via zip (for subdirs and symbolic links).
    local changed_files
    changed_files="$(git-diff-list)"
    local restore_dir=""
    if [ "$changed_files" != "" ]; then

        # Require force to perform update when there are changed files
        local git_force="${GIT_FORCE:-0}"
        ## DEBUG: echo "git-update-plus: git_force=$git_force"
        if [ "$git_force" = "0" ]; then
            echo "Error: Use 'git-update-force' to update with changed files (n.b., potential for conflicts)"
            return
        fi
            
        if [ "${PRESERVE_GIT_STASH:-0}" = "1" ]; then
            # Make sure root active for relative path names in zip file
            local root_dir
            root_dir="$(git-root-alias)"
            if [ "$PWD" != "$root_dir" ]; then
                echo "Temporarily changing working directory to root: $root_dir"
                restore_dir="$PWD"
                cd "$(git-root-alias)"
            fi

            # Create zip (-v for verbose & -y for symlinks)
            command rm -f _stash.zip
            echo "issuing: zip over changed files (for later restore)"
            echo "git-diff-list | zip -v -y -@ _stash.zip" >> "$log"
            git-diff-list | zip -v -y -@ _stash.zip >> "$log"
        else
            # note: zip options: -y retain links; -v verbose
            echo "Not zipping changes because PRESERVE_GIT_STASH not 1"
        fi
    else
        echo "No changed files so no pre-stash-pop timestamp check"
    fi

    # Do the stash[-push]/pull/stash-pop
    echo "issuing: git stash"
    git stash >> "$log"
    echo "issuing: git pull --all"
    git pull --all >> "$log"
    if [ $? -ne 0 ]; then
        echo "Warning: problem with pull (status=$?)"
    fi
    echo "issuing: git stash pop"
    git stash pop >> "$log"

    # Optionally restore timestamps for changed files
    if [ "$changed_files" != "" ]; then
        if [ "${PRESERVE_GIT_STASH:-0}" = "1" ]; then
            echo "issuing: unzip over _stash.zip (to restore timestamps)"
            # note: unzip options: -o overwrite; -v verbose:
            echo "unzip -v -o _stash.zip" >> "$log"
            unzip -v -o _stash.zip >> "$log"
            
            # Restore working directory
            if [ "$restore_dir" != "" ]; then
                echo "Restoring working directory: $restore_dir"
                cd "$restore_dir"
            fi
        else
            echo "Not unzipping changes (because PRESERVE_GIT_STASH not 1)"
        fi
    else
        echo "No changed files so no post-stash-pop timestamp check"
    fi

    # Show end of log
    # TODO: filter unzip output
    echo >> "$log"
    git-alias-review-log "$log"
}

# git-update-force(): Run git-update-plus with forced update
# note: used to avoid overly conservative git-update-plus
#
function git-update-force {
    GIT_FORCE=1 git-update-plus
}

# git-update-verified(): Run git-update-force if user agrees
#
function git-update-verified {
    local changed
    changed=$(git-diff-list)
    if [ "$changed" != "" ]; then
        echo "Current changes: $changed"
        pause-for-enter "Proceed with update even though potential for conflict? (Enter for Y otherwise ^C)"
    fi
    git-update-force
}

function git-rename-file {    # Rename file OLD to NEW and update index
    local old_file="$1"
    local new_file="$2"
    
    invoke-git-command mv "$old_file" "$new_file"
    git-commit-and-push "$new_file"
    # do same as git-revert-file-alias
    invoke-git-command reset HEAD "$old_file"
}


# git-move-to-dir(dir, file1, file2, ...)
function git-move-to-dir {    # Move files to specified directory
    local dir="$1"
    shift
    local file
    for file in "$@"; do
        invoke-git-command mv "$file" "$dir"
        # TODO2: cut down on extraneous confirmations
        git-commit-and-push "$dir/$file"
    done
}

# sets globals for user, password (or token), etc. by sourcing external file
# note: deprecated approach checking for _my-git-credentials-etc.bash.list in current dir and home dir
function set-global-credentials {
    local credentials_file="_my-git-credentials-etc.bash.list"
    # Note: check stored credentials
    if [[ -e ~/.git-credentials ]]; then
        echo "Using git-based credentials via ~/.git-credentials"
    else
        echo "Warning: use deprecated credentials file sourcing"
        for dir in . ~; do
            if [[ ($git_user = "") && (-e "$dir/$credentials_file") ]]; then
                echo "Sourcing credentials ($dir/$credentials_file)"
                source "$dir/$credentials_file"
                break
            fi
        done
   fi
}

# git-add-commit-push(file, ...): commits FILE... to local repo, which is then
# pushed to global repo
# note:
# - [deprecated] gets user credentials from ./_my-git-credentials-etc.bash.list
# - also does an implicit add unless GIT_SKIP_ADD (TODO3: rename to git-add-commit-and-push?)
# TODO: add message argument
function git-add-commit-push {
    local file_spec="$*"
    local log
    log=$(get-temp-log-name "commit")
    #
    # TODO: rework so that message passed as argument (to avoid stale messages from environment)
    local message="${GIT_MESSAGE:-...}"
    if [ "$message" = "..." ]; then 
        echo "Error: '...' or '' not allowed for commit message"
        echo "This avoids to avoid cut-n-paste error (e.g., [G]IT_MESSAGE-typo)"
        return 1
    fi
    ## OLD:
    ## if [ "$message" = "..." ]; then 
    ##     echo "Error: '...' not allowed for commit message (to avoid cut-n-paste error)"
    ##     return 1
    ## fi
    ## if [ "$message" = "" ]; then
    ##     echo "Error: '' not allowed for commit message (to avoid [G]IT_MESSAGE-typo error)"
    ##     return 1
    ## fi
    #
    local git_user="n/a"
    local git_token="n/a"
    if [ "$UNSAFE_GIT_CREDENTIALS" = "1" ]; then
       set-global-credentials
       echo "git_user: $git_user;  git_token: $git_token"
    fi
    #
    local dir
    if [ "$file_spec" = "" ]; then
        echo "Warning: *** No file specified (cuidado!)"
    elif [ "${GIT_SKIP_ADD:-0}" = "1" ]; then
        echo "skipping: git add $*"
    else
        echo "issuing: git add" "$@"
        git-add-plus "$@" >> "$log"
    fi

    # Push the changes after showing synopsis and getting user confirmation
    echo ""
    pause-for-enter "About to commit $file_spec (with message '$message')"
    echo "issuing: git commit -m '$message'"
    git commit -m "$message" >> "$log"
    perl -pe 's/^/    /;' "$log"
    pause-for-enter 'About to push: review commit log above!'
    #
    echo "issuing: git push --verbose"
    if [ "$UNSAFE_GIT_CREDENTIALS" = "1" ]; then
       git push --verbose <<EOF >> "$log"
$git_user
$git_token
EOF
    else
       git push --verbose >> "$log"
    fi
    echo >> "$log"

    # Sanity check
    git-alias-review-log "$log"
}
#
# note: following for backward compatibility
simple-alias-fn git-commit-and-push git-add-commit-push


# git-update-commit-push(file, ...): updates local repo and then commits FILE... to global repo
# TODO: skip commit if problem with update
function git-update-commit-push {
    # DEBUG: set -o xtrace
    git-update-force
    if [ $? -ne 0 ]; then
        echo "Warning: consider canceling given possible update error (status=$?)"
    fi
    git-commit-and-push "$@"
    # DEBUG: set - -o xtrace
}
#
# git-update-commit-push-all(): adds all files for checkin
alias git-update-commit-push-all='git-update-commit-push *'

# run git COMMAND with output saved to command-specific temp file
#
function invoke-git-command {
    local command="$1"
    shift
    local log
    log=$(get-temp-log-name "$command")
    echo "issuing: git $command $*"
    git "$command" "$@" >| "$log" 2>&1
    ## PREVIOUS: less
    ## NOTE: unfortunately, less clears the screen
    ## TODO: less --quit-if-one-screen "$log"
    cat "$log"
    # TODO: git-alias-review-log "$log"
}
# TODO: git-command => git-command-alias
alias git-command='invoke-git-command'
alias git-push-plus='invoke-git-command push'

# Misc git commands (redirected to log file)
# NOTE: commands with much output like git-log invoke less
# TODO: add invoke-git-command-paged wrapper (a la git ... | less)
alias git-status='invoke-git-command status'
function git-log-plus { invoke-git-command log --name-status "$@" | less --quit-if-one-screen; }
# note: git-log-diff-plus shows diff-style log
alias git-log-diff-plus='invoke-git-command log --patch'
alias git-log-follow='git-log-plus --follow'
alias git-blame-alias='invoke-git-command blame'

# git-add-plus: add filename(s) to repository
# note: if GIT_FORCE is 1 then --force added (e.g., to override .gitignore)
function git-add-plus {
    local log;
    log=$(get-temp-log-name "add");
    local options=""
    if [ "$GIT_FORCE" = "1" ]; then options="--force"; fi
    git add $options "$@" >| "$log" 2>&1;

    # Sanity check
    git-alias-review-log "$log"
}


# git-reset-file(file, ...): move FILE(s) out of way and "revert" to version in repo (i.e., reset)
# NOTE: via https://www.atlassian.com/git/tutorials/undoing-changes/git-reset
#     If git revert is a “safe” way to undo changes, you can think of git reset as the dangerous method.
# Also see
#     https://stackoverflow.com/questions/1125968/how-do-i-force-git-pull-to-overwrite-local-files
#     https://stackoverflow.com/questions/11200839/why-git-cant-do-hard-soft-resets-by-path
# TODO: clarify whether git add needed as well (due to maldito git)
function git-reset-file {
    local log;
    log=$(get-temp-log-name "revert");
    ## TODO:
    ## local reset_options=""
    ## if [ "$1" = "--hard" ]; then
    ##     reset_options="$1";
    ##     shift
    ##     pause-for-enter $'Warning: reset --hard changes the both index and working tree!\nPress enter to proceed'
    ## fi
    if [ "$*" = "" ]; then
        echo "Error: need to specify a file"
        return 1
    fi

    # Isolate old versions
    mkdir -p _git-trash >| "$log";
    echo "issuing: cp -vpf $* _git-trash";
    # Note: Uses  'command cp' to avoid confirmation when same file already in trash.
    # This is a design decision since resets aren't common (e.g., vs. timestamping trash files).
    command cp -vpf "$@" _git-trash >> "$log";

    # Forget state
    echo "issuing: git reset HEAD $*";
    git reset HEAD "$@" >> "$log";
    ## TODO: git reset HEAD $reset_options "$@" >> "$log";
    ## NOTE: leads to "Cannot do hard reset with paths" error
    
    # Re-checkout
    # TODO: add option for 'git checkout HEAD -- ...'???
    echo "issuing: git checkout -- $*";
    git checkout -- "$@" >> "$log";

    # Issue warning if stash non-empty
    echo "issuing: git stash list"
    local stash
    stash=$(git stash list)
    if [ "$stash" != "" ]; then
        echo "Warning: non-empty stash:"
        echo "$stash" | perl -pe 's/^/    /;'
        echo "Consider issuing following: git stash drop"
    fi

    # Sanity check
    git-alias-review-log "$log"
}
#
# Note: git-reset-file is a soft reset: a hard reset would only done explcitly via
# --hard and moreover would lead to a warning requiring confirmation.
# (In addition, the support for --hard is currently disabled.)
alias git-revert-file-alias='git-reset-file' 
## TODO: alias git-reset-hard-alias='git-reset-file --hard'

# git-restore-file-alias(file, ...): move FILE(s) out of way and "revert" to version in repo (i.e., reset)
# NOTE: via https://stackoverflow.com/questions/7751555/how-to-resolve-git-stash-conflict-without-commit:
#     Use 'git restore --staged' to mark conflict as resolved and unstage
function git-restore-file-helper {
    local log;
    local option="$1"
    shift
    log=$(get-temp-log-name "restore");
    if [ "$option" = "--both" ]; then
        option="--worktree --staged"
    fi

    # Isolate old versions
    mkdir -p _git-trash >| "$log";
    echo "issuing: cp -vpf $* _git-trash";
    # Note: Uses  'command cp' to avoid confirmation when same file already in trash.
    # This is a design decision since restores aren't common (e.g., vs. timestamping trash files).
    command cp -vpf "$@" _git-trash >> "$log";

    # Restore working tree files
    echo "issuing: git restore $option $*";
    # shellcheck disable=SC2086
    git restore $option "$@" >> "$log";
    
    # Sanity check
    git-alias-review-log "$log"
}
alias git-restore-worktree-alias="git-restore-file-helper --worktree"
alias git-restore-staged-alias="git-restore-file-helper --staged"
alias git-restore-both-alias="git-restore-file-helper --both"

# git-revert-commit(commit): effectively undoes COMMIT(s) by issuing new commits
alias git-revert-commit-alias='git-command revert'

# git-diff-plus: show repo diff
function git-diff-plus {
    local log;
    log=$(get-temp-log-name "diff");
    # Perform diff and convert a/ and /b path prefixes to 'a: ' and 'b: '
    # ex: diff --git a/.github/act.yml b/.github/... => "diff --git a: .github/,,,"
    # ex: --- "a/.github/act.yml" => "--- a: .github/act.yml"
    ## TODO? (account for subdirectories 'a' or 'b'):
    ## git diff "$@" | perl -pe 's@^(diff|\-\-\-|\+\+\+) (?!.*[ab]/.*)([ab])/@\1\2 \3: @;' >| "$log";
    ## Note: uses git-diff-list[-template] so file order reflects subdir embedding level
    ## OLD: git diff "${files[@]}" | perl -pe 'while(s@^(diff|\-\-\-|\+\+\+)(.*) ([ab])/@\1\2 \3: @g) {}' >| "$log";
    local OLDIFS=$IFS                   # save inter-field separator
    echo "" > "$log"
    for f in $(git-diff-list); do
        git diff "$f" | perl -pe 'while(s@^(diff|\-\-\-|\+\+\+)(.*) ([ab])/@\1\2 \3: @g) {}' >> "$log"
    done
    IFS=$OLDIFS                         # restore inter-field separator
    #
    less -p '^diff' "$log";
    ## TODO: less --quit-if-one-screen --pattern='^diff' "$log";
}

# git-difftool-plus: visual repo diff
# git-vdiff: alias w/ & (i.e., run in background)
# Note: the tool must be configured separately (e.g., ~/.gitconfig)
#   [difftool "kdiff3"]
#       path = /usr/bin/kdiff3
#       trustExitCode = false
# TODO1: work around quirk with plain diff being invoked in certain situations (e.g., merge conflict)
#
function git-difftool-plus {
    ## TODO: add trace-command function
    ## TODO: echo "issuing: git difftool --no-prompt ..." 1>&2
    git difftool --no-prompt "$@";
}
#
# maldito Bash:
# TODO: see if way to have functions trump aliases
#
function git-vdiff-alias {
    ## DEBUG: echo in git-vdiff;
    git-difftool-plus "$@" &
    }

# Produce listing of changed files
# note:
# - Used in check-in templates, so level of indirection involved
# - Uses following one-line from ChatGPT
#     git diff --name-only | awk -F'/' '{ print NF-1 "\t" $0 }' | sort --key=1 --numeric-sort | cut -f2-
#   where -F'/' sets the field separator to /; awk splits line and prints the depth (i.e., #/'s - 1) plus line;
#   it then sorts the output and removes the depth count.
#
function git-diff-list-template {
    # TODO: use unique tempfile (e.g., mktemp)
    ## TODO2: diff_list_file=$(get-temp-log-name "diff")
    echo "diff_list_file=\$TMP/_git-diff.\$\$.list"
    # ex: "diff --git a/tomohara-aliases.bash b/tomohara-aliases.bash" => "tomohara-aliases.bash:
    # TODO: ex: "diff --cc mezcla/data_utils.py" => "mezcla/data_utils.py"
    ## OLD: echo "git diff 2>&1 | extract_matches.perl '^diff.* b/(.*)' >| \$diff_list_file"
    ## TODO3: rework to avoid shellcheck warning [SC2028 (info): echo may not expand escape sequences. Use printf.]
    # shellcheck disable=SC2028
    echo "git diff --name-only | awk -F'/' '{ print NF-1 \"\t\" \$0 }' | sort --key=1 --numeric-sort | cut -f2- >| \$diff_list_file"
}
function git-diff-list {
    local diff_list_file
    ## TODO2: local diff_list_script=$(get-temp-log-name "diff")
    local diff_list_script="$TMP/_git-diff-list.$$.bash"
    git-diff-list-template >| "$diff_list_script"
    source "$diff_list_script"

    # Change path to absolute and drop current directory
    # note: in case of sibling directories the root is shown via a variable
    # (e.g., "/home/tomohara/python/Mezcla/README.md" => "$(git-root-alias)/README.md"
    # TODO3: simplying regex fixup's; use relative path (e.g., "../README.md")
    local root
    root=$(git-root-alias)
    local pwd
    pwd=$(realpath ".")
    # shellcheck disable=SC2002
    cat "$diff_list_file" | perl -pe "s@^@$root/@;" | perl -pe "s@^$pwd/?@@;" | perl -pe "s@^$root/?@\\\$\(git-root-alias\)/@;"
}

# Output templates for doing checkin of modified files
function git-checkin-template-aux {
    git-diff-list-template
}
#
function git-checkin-single-template {
    git-checkin-template-aux
    echo "# To check in one file (ideally with main differences noted):"
    echo "mod_file=\$(head -1 < \"\$diff_list_file\"); git-difftool-plus \"\$mod_file\""
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
    echo "echo GIT_MESSAGE=\'misc. update\' git-update-commit-push \$(cat \$diff_list_file)"
}

# invoke-next-single-checkin: outputs and runs the next single-checking template
function invoke-next-single-checkin {
    # TODO: use unique tempfile (e.g., mktemp)
    git-checkin-single-template >| "$TMP/_template.sh"
    source "$TMP/_template.sh"
}
#
# alt-invoke-next-single-checkin([filename]) alternative version that uses readline
# with template text for checking in next change (or FILENAME if given)
# NOTE: although potentially dangerous given eval environnment, the user still needs to
# confirm the commit operation (and thus can verify done OK).
# This is used for git-next-checkin with an empty filename.
function alt-invoke-next-single-checkin {
    # If unspecified, determine file to check in, based on next modified file
    local mod_file="$1"
    if [ "$mod_file" = "" ]; then
        mod_file=$(git-diff-list | head -1);
        if [ "$mod_file" = "" ]; then
            echo "Warning: unable to infer modified file. Perhaps,"
            echo "    Tha-tha-that's all folks"'!'
            echo ""
            local divider
            divider=$(perl -e 'print("." x 80);')
            echo "$divider"
            git-status
            echo "..."
            return;
        fi
    fi

    # Read the user's commit message
    # note: shows visual diff (TODO: and pauses so user can start message)
    # TODO: position cursor at start of ... (instead of pause)
    local is_text
    ## TODO: fix problem identifying scripts with UTF-8 as text (e.g., common.perl reported as data by file command)
    is_text=$(file "$mod_file" | egrep -i ':.*(text|JSON|UTF-8)')
    ## HACK: add special case exceptions
    if [ "$is_text" = "" ]; then
        case "$mod_file" in *.css | *.csv | *.html | *.ipynb | *.java | *.js | *.perl | *.py | *.[a-z]*sh | *.text| *.txt) is_text="1"; echo "Special case hack for braindead file command (known program extension in $mod_file)" ;; esac
    fi;
    if [ "$is_text" != "" ]; then
        if [ "$GIT_NO_CONFIRM" = "1" ]; then
            echo "GIT_NO_CONFIRM enabled, so skipping difftool (e.g., for visual diff)"
        else
            # note: pauses a little so that user can update cursor before focus shifts
            # TODO: see how to keep focus on terminal window for git update
            local delay=5
            echo "issuing: (sleep $delay; git-difftool-plus \"$mod_file\") &"
            (sleep $delay; git-difftool-plus "$mod_file") &
        fi
    else
        ## TODO: summarize binary differenecs
        echo "Note: binary file so bypassing diff"
        git diff --numstat "$mod_file" | head
        true
    fi
    local prompt="GIT_MESSAGE=\"...\" git-update-commit-push \"$mod_file\""
    local command
    echo "TODO: modify the GIT_MESSAGE (escaping $'s, etc.) and verify read OK in commit confirmation."
    local OLD_GIT_MESSAGE=$GIT_MESSAGE
    # note: options: -e use readline; -i initialize readline buffer; -r backslash is not an escape
    if [ "$GIT_NO_CONFIRM" = "1" ]; then 
        echo "GIT_NO_CONFIRM set to 1, so skipping git-update-commit-push confirmation"
        export GIT_MESSAGE=${GIT_TEST_MESSAGE:-"default"}
        command="git-update-commit-push \"$mod_file\""
    else 
        read -r -e -i "$prompt" command
    fi
    # Evaluate the user's checkin command
    # TODO: rework using a safer approach with reading checking comment and issuing git-update-commit-push directly
    ## DEBUG:
    ## echo "Running (n,b, *** be careful nothing lost ***):"
    ## echo "   $command"
    eval "$command"

    # Restore message
    export GIT_MESSAGE=$OLD_GIT_MESSAGE

    # Start next checkin or show if no more updates to do
    git-next-checkin
}
#
# invoke-alt-checkin(filename): run alternative template-based checkin for filename
function invoke-alt-checkin { alt-invoke-next-single-checkin "$1"; }

# Various miscellaneous aliases
alias git-template=git-alias-usage
alias git-template-misc=git-misc-alias-usage
alias git-root-alias='git rev-parse --show-toplevel'
alias git-cd-root-alias='cd $(git-root-alias)'
alias git-invoke-next-single-checkin=invoke-next-single-checkin
# NOTE: squashes maldito shellcheck warning (i.e., SC2139: This expands when defined)
# shellcheck disable=SC2139
alias-fn git-alias-refresh "source '${BASH_SOURCE[0]}'"    # bash idiom for current script filename
simple-alias-fn git-refresh-aliases 'git-alias-refresh'
simple-alias-fn git-next-checkin 'invoke-alt-checkin'      # uses alt-invoke-next-single-checkin
simple-alias-fn git-extract-all-versions 'extract-all-git-versions.bash'
## TEST: hide tracing output alias git-next-checkin='invoke-alt-checkin 2> /dev/null'
# git-tar-repo(): create tar archive of entire repo
alias git-tar-repo=tar-this-dir-dated
# git-tar-repo-proper(): create tar archive of repo excluding .git
# note: this is to create backup before updating repo (in case of conflicts)
alias git-tar-repo-proper='TAR_FILTER="\.git\b" tar-this-dir-dated'
#
# TODO2: add some type of confirmation
alias git-checkin-new-alias="GIT_MESSAGE='initial version' git-update-commit-push"

# TODO:
# NOTE: maldito git is too polymorphic, making it difficult to limit and easy to mess thing up!
function git-checkout-branch {
    local branch="$1"
    # TODO2: define helper function for usage
    if [[ ("$branch" = "") || ("$branch" == "--help") ]]; then
        echo "usage: git-checkout-branch [--help | branch]"
        echo "note: available branches:"
        # TODO: get maldito git to cooperate better (e.g., plain text option)!
        # shellcheck disable=SC2016
        PAGER="" git branch --all | extract_matches.perl -replacement='    $1' 'remotes/origin/(\S+)$'
        return
    fi
    local branch_ref
    branch_ref=$(git branch --all | grep -c "$branch")
    if [ "$branch_ref" -gt 0 ]; then
        # note: uses -- after branch to avoid ambiguity in case also a file [confounded git!]
        git-command checkout "$branch" --;
    else
        echo "Error: unknown branch '$branch'"
    fi;
}
simple-alias-fn git-branch-checkout  git-checkout-branch 

# git-branch-alias(): return current branch for repo
function git-current-branch {
    local git_branch
    git_branch="$(git status | extract_matches.perl "On branch (\S+)")"
    echo "$git_branch"
}
alias git-branch-alias='git-current-branch'

# git-conflicts-alias(): show conflicts in the local git repo
function git-conflicts-alias {
    ## TODO3: get ls-tree to show output relative to current subdirectory
    local restore_dir="$PWD"
    git-cd-root-alias
    git ls-tree -r --full-tree --name-only HEAD | xargs -I '{}' grep --with-filename '^<<<<<<<' {};
    cd "$restore_dir"
}

#-------------------------------------------------------------------------------

# git-alias-usage (): tips on interactive usage (n.b., aka git-template)
# shellcheck disable=SC2016
function git-alias-usage () {
    # Refresh
    ## TODO2: fix refresh problem: manual git-alias-refresh required; also, make optional
    git-alias-refresh

    # Show usage
    echo "Usage examples for git aliases, most of which create log files as follows:"
    echo "   _git-CMD-MMDDYY-HHMM-tmp.log      # ex: _git-status-03jul22-1105-HTV.log"
    echo ""
    # note: 'clear's -x option doesn't clobber history (to work around a disruptive Linux change that fell through maldito Q&A cracks!)'
    echo "Get changes from repository (set PRESERVE_GIT_STASH=1 to keep timestamps)":
    echo "    git-update-plus"
    echo ""
    echo "To add regular files to repo (via git-add):"
    echo "    GIT_MESSAGE='initial version' git-update-commit-push file..."
    echo "Note: use GIT_FORCE=1 ... if file matches .gitignore patterns"
    echo ""
    echo "To check in specified changes:"
    echo "    GIT_MESSAGE='...' git-update-commit-push file..."
    echo ""
    echo "To switch to another branch (n.b., to list, use 'git branch --list --all'):"
    echo "    git-checkout-branch"
    echo ""
    echo "Miscellaneous alias template (e.g., for deletions):"
    echo "    git-template-misc"
    echo ""
    echo "Check-in specific file:"
    local next_mod_file
    next_mod_file=$(git-diff-list 2> /dev/null | head -1)
    if [ "$next_mod_file" = "" ]; then next_mod_file="TODO:filename"; fi
    echo '    git-next-checkin "'${next_mod_file}'"'
    echo ''
    echo 'Usual check-in process:'
    # TODO2: rework git-update-force via dry-run git-update with conflict check
    echo '    git-cd-root-alias; git-tar-repo-proper; git-update-force; git-next-checkin'
    echo '    # -or-: git-cd-root-alias; git-update-verified; git-conflicts-alias; git-next-checkin'
    echo '    git-next-checkin                      # repeat, as needed'

    ## TODO: echo '* invoke git-cd-root-alias automatically!'
}

# git-misc-alias-usage: Show miscelleanous tips
#
# Notes:
# - Unfortunately just for next statement, so applied to entire funtion
#    See https://github.com/koalaman/shellcheck/issues/1295 [Allow directives in trailing comments].
#
# shellcheck disable=SC2016
function git-misc-alias-usage() {
    # Refresh
    git-alias-refresh

    # Show usage
    echo "Warning: Some of these can be dangerous!"
    echo "   Incorrect usage might be undoable (e.g., disconnected histories with mv)."
    echo "   *** It is safer to use github web interface instead!"
    echo ""
    echo "To revert modified file (n.b., during merge fix, dummy change might be needed):"
    echo "    git-revert-file-alias file"
    echo "You also might need the following (or git-restore-{worktree|both}-alias:"
    echo "    git-restore-staged-alias file"
    echo ""
    echo "To override file additions (e.g., blocked by .gitignore):"
    echo "    GIT_FORCE=1 GIT_MESSAGE='...' git-update-commit-push file..."
    echo ""
    echo "To use git manual merge resolution (n.b., trial and error required):"
    echo "    git mergetool"
    echo ""
    echo "To move or rename (cuidado):"
    echo "    GIT_MESSAGE='renamed' git-rename-file OLD NEW-file"
    echo "    GIT_MESSAGE='moved' git-move-to-dir DIR file1 file2"
    echo ""
    echo "To delete files (mucho cuidado):"
    echo "   git rm old-file"
    echo "   GIT_MESSAGE='deleted' git-update-commit-push old-file"
    echo ""
    echo "To check in all tracked with changed:"
    echo "    git-checkin-multiple-template >| \$TMP/_template.sh; source \$TMP/_template.sh"
    echo "A lazy-man's alternative, only recommended for single-user repos:"
    echo "    git-checkin-all-template >| \$TMP/_template.sh; source \$TMP/_template.sh"
    echo ""
    echo "Source code grepping:"
    ## OLD: echo ## OLD: "   (git ls-tree -r --full-tree --name-only HEAD | xargs -I '{}' grep --with-filename 'pattern' {}) | less"
    ## TODO3: get ls-tree to show output relative to current subdirectory
    echo "   (git-cd-root-alias; git ls-tree -r --name-only HEAD | xargs -I '{}' grep --with-filename 'pattern' {}) | less"
    echo ""
    echo "Odds and ends:"
    echo '   head $(git-root-alias)/config'
    echo '   git-alias-refresh'
}
