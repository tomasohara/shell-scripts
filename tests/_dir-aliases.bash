#! /usr/bin/env bash
# -*- coding: utf-8 -*-

## via tomohara-aliases.bash
## trace directory commands

# Support for ls (list directory contents)
# 
# ls options: # --all: all files; -l long listing; -t by time; --human-readable: uses numeric suffixes like MB; --no-group: omit file permision group; --directory: no subdirectory listings.
# TODO: Add --long as alias for -l to ls source control and check-in [WTH?]! Likweise, all aliases for other common options without long names (e.g., -t).
#
LS="/bin/ls"
core_dir_options="--all -l -t  --human-readable"
dir_options="${core_dir_options} --no-group"
# maldito shellcheck: SC2046 [Quote this to prevent word splitting] and SC2086 [Double quote to prevent globbing]
# shellcheck disable=SC2046,SC2086
{
if [ "$OSTYPE" = "solaris" ]; then dir_options="-alt"; fi
if [ "$BAREBONES_HOST" = "1" ]; then dir_options="-altk"; fi
function dir () {
    local opts="$dir_options"
    # note: see https://stackoverflow.com/questions/1853946/getting-the-last-argument-passed-to-a-shell-script
    local dir="${!#}"
    # hack: only shows directory contents if name ends in slash (e.g., /etc/)
    # note: pattern is POSIX extended regular expression as per bash manual
    local regex="^.*/$";
    if [[ (! (($dir != "") || ($dir =~ $regex))) ]]; then
        opts="$opts --directory";
    fi
    $LS ${opts} "$@" 2>&1 | $PAGER;
function dir-proper () { $LS ${dir_options} --directory "$@" 2>&1 | $PAGER; }
alias ls-full='$LS ${core_dir_options}'
function dir-full () { ls-full "$@" 2>&1 | $PAGER; }
## TODO: WH with the grep (i.e., isn't there a simpler way)?
function dir-sans-backups () { $LS ${dir_options} "$@" 2>&1 | $GREP -v '~[0-9]*~' | $PAGER; }
# dir-ro/dir-rw(spec): show files that are read-only/read-write for the user
function dir-ro () { $LS ${dir_options} "$@" 2>&1 | $GREP -v '^..w' | $PAGER; }
function dir-rw () { $LS ${dir_options} "$@" 2>&1 | $GREP '^..w' | $PAGER; }

function subdirs () { $LS ${dir_options} "$@" 2>&1 | $GREP ^d | $PAGER; }
#
# subdirs-proper(): shows subdirs in colymn format omitting ones w/ leading dots
# note: omits cases like ./ and ./.cpan from find and then removes ./ prefix
quiet-unalias subdirs-proper
function subdirs-proper () { find . -maxdepth 1 -type d | $EGREP -v '^((\.)|(\.\/\..*))$' | sort | perl -pe "s@^\./@@;" | column; }
# note: -f option overrides -t: Unix sorts alphabetically by default
# via man ls:
#   -f     do not sort, enable -aU, disable -$LS --color
# TODO: simplify -t removal (WTH with perl regex replacement?!)
function dir_options_sans_t () { echo "$dir_options" | perl -pe 's/\-t//;'; }
function subdirs-alpha () { $LS $(dir_options_sans_t) "$@" 2>&1 | $GREP ^d | $PAGER; }
function sublinks () { $LS ${dir_options} "$@" 2>&1 | $GREP ^l | $PAGER; }
function sublinks-alpha () { $LS $(dir_options_sans_t) "$@" 2>&1 | $GREP ^l | $PAGER; }
}
# TODO: show non-work-related directory example
#
alias symlinks='sublinks'
# symlinks-proper: just show file name info for symbolic links, which starts at column 43
alias symlinks-proper='symlinks | cut --characters=43-'
#
function sublinks-proper { sublinks "$@" | cut --characters=42-  | $PAGER; }
alias symlinks-proper=sublinks-proper
#
alias glob-links='find . -maxdepth 1 -type l | sed -e "s/.\///g"'
alias glob-subdirs='find . -mindepth 1 -maxdepth 1 -type d | sed -e "s/.\///g"'
#
alias ls-R='$LS -R >| ls-R.list; wc -l ls-R.list'
#
# TODO: create ls alias that shows file name with symbolic links (as with ls -l but without other information
# ex: ls -l | perl -pe 's/^.* \d\d:\d\d //;'
}

# link-symbolic-safe: creates symbolic link and avoids quirks with links to directories
# EX: link-symbolic-safe /tmp temp-link; link-symbolic-safe --force ~/temp temp-link; ls -l temp-link | grep /tmp => ""
alias ln-symbolic='ln --symbolic --verbose'
alias link-symbolic-safe='ln-symbolic --no-target-directory --no-dereference'
alias link-symbolic-regular='ln-symbolic'
## TODO: alias ln-symbolic-force='link-symbolic --force'

