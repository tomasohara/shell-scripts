#! /usr/bin/env bash
#
# Wrapper aroung git-template alias and also invokes a bash shell
# note: used in script-update alias to show template in new shell for git updates

## DEBUG:
echo "$0 $*"

# Enable Bash aliases, etc.
## maldito shellcheck: [SC1090: Can't follow non-constant source]
# shellcheck disable=SC1090
{
    shopt -s expand_aliases
    ## BAD:
    ## source ~/bin/tomohara-aliases.bash
    ## source ~/bin/tomohara-proper-aliases.bash
    ## source ~/bin/tomohara-settings.bash
    src_dir="$(dirname "${BASH_SOURCE[0]}")"
    bin_dir="${src_dir}/.."
    source "$bin_dir/tomohara-aliases.bash"
    source "$bin_dir/tomohara-proper-aliases.bash"
    source "$bin_dir/tomohara-settings.bash"
}

# Show template and then start a bash session
git-template
bash -i
