#! /usr/bin/env bash
#
# Adhoc script to update all of the user's main repositories. They can be
# specified on the command lines or in the OTHER_REPOS env var.
#
## UPDATE 16 Jul 26: cleanup
## 
## # adhoc script to update all repo's
## # UPDATE 08 Aug 26: adds repo branch to verbose output
## # UPDATE: 28 Jun 2020: upgrade including support for OTHER_REPOS as string list or array
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  echo "$@"
## set -o xtrace
## DEBUG: set -o verbose

# Show usage if requested
show_summary="${SHOW_SUMMARY:-1}"
repos=()
if [ "$1" == "--help" ]; then
    script=$(basename "$0")
    # TODO2: make repos an argument and drop ~/bin, etc.
    echo "Usage: [env] $script [--help] [repo ...]"
    echo '    env: OTHER_REPOS="string-list" SHOW_SUMMARY=B VERBOSE_MODE=B'
    echo ""
    echo "Examples:"
    echo ""
    echo "OTHER_REPOS=\"repo1 repo2\" $0"
    echo ""
    echo "SHOW_SUMMARY=0 VERBOSE_MODE=1 $script repo-dir1 ..."
    echo ""
    echo "Note:"
    echo "- OTHER_REPOS is space-delimited: specify repos via positional argument(s) otherwise."
    echo "- SHOW_SUMMARY shows current repo status"
    echo "- VERBOSE_MODE adds repo url, branch, and related info"
    exit
fi
if [ "$1" != "" ]; then
    repos+=("$@")
fi

# Trace startup
# TODO3: fix quirk with doing this after sourcing aliases below
if [ "${DEBUG_LEVEL:-0}" -ge 5 ]; then
    echo "in" "$@"
fi

# Enable Bash aliases, etc.
## maldito shellcheck: [SC1090: Can't follow non-constant source]
## and [SC1091: Not following: ... was not specified as input (see shellcheck -x)]
# shellcheck disable=SC1090,SC1091
{
    shopt -s expand_aliases
    src_dir="$(dirname "${BASH_SOURCE[0]}")"
    bin_dir="${src_dir}/.."
    ## OLD:
    ## source "$bin_dir/tomohara-aliases.bash"
    ## source "$bin_dir/tomohara-proper-aliases.bash"
    ## source "$bin_dir/tomohara-settings.bash"
    SOURCE_SETTINGS=1 source "$bin_dir"/all-tomohara-aliases-etc.bash
}

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Initialize
mkdir -p ~/config ~/temp
log=~/config/_update-all-repos-$(T).log
temp_log=~/temp/_update-all-repos-$(T).temp.log
rename-with-file-date "$log" "$temp_log" &> /dev/null
## TODO4: resolve problem w/ $* leading to 'histappend'
## DEBUG: echo "${BASH_SOURCE[0]} $*" | tee "$log"
echo "in $0: $(date)" >> "$log"

# Determine directories
# pre-init: OTHER_REPOS="$HOME/text-categorization $HOME/programs/python/visual-diff"
if [ "$OTHER_REPOS" != "" ]; then
    ## TODO2: drop array support as it requires sourcing the script
    if declare -p OTHER_REPOS 2>/dev/null | grep -q 'declare \-a'; then
        ## DEBUG: echo "OTHER_REPOS as array"
        repos+=("${OTHER_REPOS[@]}")
    else
        # fallback: space-delimited string
        ## DEBUG: echo "OTHER_REPOS as string list"
        read -r -a tmp <<< "$OTHER_REPOS"
        repos+=("${tmp[@]}")
    fi
fi
if [ ${#repos[@]} -eq 0 ]; then
    # TODO: drop idiosyncratic repos (e.g., non-public)
    repos=(~/bin ~/mezcla ~/text-categorization ~/visual-diff ~/programs/bash/tom-shell-scripts ~/programs/python/mezcla-clone ~/programs/python/search-diff-engine)
fi
## DEBUG: set | grep ^repos=

# Update each directory
## UPDATE 15 Jul 26: adds VERBOSE_MODE support to show repo URL
## TODO2: verbose_mode=$(getenv-bool "VERBOSE_MODE" false)
verbose_mode=$(is-true "VERBOSE_MODE")
$verbose_mode && echo "$0"
## DEBUG: trace-vars verbose_mode
for dir in "${repos[@]}"; do
    # Make repo dir active
    ## OLD: command cd "$dir" || continue
    ## OLD: if [ ! -d "$dir" ]; then
    result=$(command cd "$dir" 2>&1)
    if [ -n "$result" ]; then
        ## echo "Warning: missing directory '$dir'"
        echo "Warning: unable to cd into '$dir': '$result'"
        continue
    fi

    # Show repo and url (e.g., "repo: /home/tomohara/bin [https://github.com/tomasohara/shell-scripts]"
    if $verbose_mode; then
        echo -n "$dir" | tee --append "$log"
    else
        echo "repo: $dir" | tee --append "$log"
    fi
    # 
    if $verbose_mode; then
        echo -e "\t[$(git-repo-url)]" | tee --append "$log"
    fi

    # Update, check for errors, and show summary stats
    git-update-plus 2>&1 | grep -v "No stash entries found" >| "$temp_log"
    check-errors-excerpt "$temp_log"
    if [[ "$show_summary" == "1" ]]; then
        if $verbose_mode; then
            echo -e "\t$(git-branch-alias)"
        fi
        (grep "files changed" "$temp_log" || echo "No changes") | perl -pe 's/^/\t/;'
    fi

    # Add to master log
    cat "$temp_log" >> "$log"
    python -c 'print("-" * 80);' >> "$log"
done

# Mention log location
if [[ "$show_summary" == "1" ]]; then
    echo "For details, see $log"
fi
