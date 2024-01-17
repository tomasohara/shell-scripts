#! /usr/bin/env bash
#
# adhoc script to update all repo's
#

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

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## DEBUG: set -o verbose
#
# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

log=~/config/_update-all-repos-$(T).log
rename-with-file-date "$log"
## TODO4: resolve problem w/ $* leading to 'histappend'
## DEBUG: echo "${BASH_SOURCE[0]} $*" | tee "$log"
echo "in $0: $(date)" >> "$log"
# pre-init: OTHER_REPOS="$HOME/text-categorization $HOME/programs/python/visual-diff"
other_repos="${OTHER_REPOS:-}"
for dir in ~/bin ~/mezcla ~/visual-diff ~/programs/bash/tom-shell-scripts ~/programs/python/tom-mezcla $other_repos; do
    echo "repo: $dir" | tee --append "$log"
    command cd "$dir"
    git-update-plus 2>&1 | grep -v "No stash entries found" >> "$log"
    python -c 'print("-" * 80);' >> "$log"
done

check-errors-excerpt "$log"
