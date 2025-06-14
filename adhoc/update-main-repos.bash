#! /usr/bin/env bash
#
# adhoc script to update all repo's
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
    echo "usage: [env] $script [--help] [repo ...]"
    echo '    env: OTHER_REPOS="..." SKIP_SUMMARY=B'
    echo "example(s):"
    echo "    OTHER_REPOS=fu $0"
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
# shellcheck disable=SC1090
{
    shopt -s expand_aliases
    src_dir="$(dirname "${BASH_SOURCE[0]}")"
    bin_dir="${src_dir}/.."
    source "$bin_dir/tomohara-aliases.bash"
    source "$bin_dir/tomohara-proper-aliases.bash"
    source "$bin_dir/tomohara-settings.bash"
}

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

mkdir -p ~/config ~/temp
log=~/config/_update-all-repos-$(T).log
temp_log=~/temp/_update-all-repos-$(T).temp.log
rename-with-file-date "$log" "$temp_log" &> /dev/null
## TODO4: resolve problem w/ $* leading to 'histappend'
## DEBUG: echo "${BASH_SOURCE[0]} $*" | tee "$log"
echo "in $0: $(date)" >> "$log"
# pre-init: OTHER_REPOS="$HOME/text-categorization $HOME/programs/python/visual-diff"
if [ "$OTHER_REPOS" != "" ]; then
    # note: ignores SC2206: Quote to prevent word splitting/globbing
    # shellcheck disable=SC2206
    repos+=($OTHER_REPOS)
fi
if [ ${#repos[@]} -eq 0 ]; then
    # TODO: drop idiosyncratic repos (e.g., non-public)
    repos=(~/bin ~/mezcla ~/visual-diff ~/programs/bash/tom-shell-scripts ~/programs/python/tom-mezcla)
fi
for dir in "${repos[@]}"; do
    # Make repo dir active
    echo "repo: $dir" | tee --append "$log"
    command cd "$dir"

    # Update, check for errors, and show summary stats
    git-update-plus 2>&1 | grep -v "No stash entries found" >| "$temp_log"
    check-errors-excerpt "$temp_log"
    if [[ "$show_summary" == "1" ]]; then
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
