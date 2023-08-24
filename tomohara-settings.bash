# idiosyncratic settings for user tomohara
#
# note:
# - New place for settings previously put in tomohara-aliases.bash.
# - This mainly is for enironment variables, Bash variables and other settings
#   not directly related to aliases or functions.
# - Selectively ignore following shellcheck warnings
#    -- SC2155: Declare and assign separately to avoid masking return values
#    -- SCnnnn: ...
# TODO:
# - ** Move misc. settings from .bashrc and tomohara-aliases.bash here.
# - Flesh out.
#

# Ensure OSTYPE is environment variable for script usage
if [ "$(printenv OSTYPE)" = "" ]; then
    export OSTYPE="$OSTYPE";
fi

# Fixup for Linux OSTYPE setting (likewise for solaris)
# TODO: use ${OSTYPE/[0-9]*/}
OSTYPE_BRIEF="$OSTYPE"
case "$OSTYPE_BRIEF" in
    linux*) export OSTYPE_BRIEF=linux; ;;
    solaris*) export OSTYPE_BRIEF=solaris;  alias printenv='printenv.sh' ;;
    darwin*) export OSTYPE_BRIEF=mac-os;  ;;
    *) echo "Warning: unknown OS type"; ;;
esac

# Add directories to path: ./bin, ./bin/<OS>
# TODO: develop a function for doing this
if [ "$(printenv PATH | $GREP "$TOM_BIN":)" = "" ]; then
   export PATH="$TOM_BIN:$PATH"
fi
if [ "$(printenv PATH | $GREP "$TOM_BIN/${OSTYPE_BRIEF}":)" = "" ]; then
   export PATH="$TOM_BIN/${OSTYPE_BRIEF}:$PATH"
fi
# TODO: make optional & put append-path later to account for later PERLLIB changes
append-path "$PERLLIB"
## OLD (see below): prepend-path "$HOME/python/Mezcla/mezcla"
append-path "$HOME/python"
append-path "$TOM_BIN/adhoc"
append-path "$TOM_BIN/examples"
append-path-warn "$HOME/.local/bin"
# Put current directoy at end of path; can be overwritting with ./ prefix
export PATH="$PATH:."

# Note: ~/lib only used to augment existing library, not pre-empt
## OLD: export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib:$HOME/lib/linux
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/lib:$HOME/lib/$OSTYPE_BRIEF"

# Setup pythonpath to include .. for sake of testing
export PYTHONPATH="$PYTHONPATH:.."

# Define HOST_NICKNAME from ~/.host-nickname if unset or the default
if [[ ("$HOST_NICKNAME" = "") || ("$HOST_NICKNAME" = "tpo-host") ]]; then
    ## OLD: export HOST_NICKNAME="$(cat ~/.host-nickname 2> /dev/null | grep -v '^#')";
    # shellcheck disable=SC2155
    export HOST_NICKNAME="$(grep -v '^#' ~/.host-nickname 2> /dev/null)";
fi

# Python stuff
## OLD: prepend-path "$HOME/python/Mezcla/mezcla"
add-python-path "$HOME/python/Mezcla/mezcla"
append-path "$HOME/mezcla-tom/examples:$HOME/python/examples:$TOM_BIN/bruno"
#
# HACK: make sure ~/mezcla-tom used if available
if [ -e "$HOME/mezcla-tom" ]; then add-python-path "$HOME/mezcla-tom"; fi
#
# Make sure gradio apps accessible in local net
# See https://superuser.com/questions/949428/whats-the-difference-between-127-0-0-1-and-0-0-0-0.
export GRADIO_SERVER_NAME=0.0.0.0
#
# Mezcla stuff
export BRIEF_USAGE=1
export TRACE_INVOCATION=1

# Enable timestamp preservation during git-update alias operations (n.b., stash pop quirk)
export PRESERVE_GIT_STASH=1

# Misc bash options
# make file globs cases insensitve
# note: also include 'set completion-ignore-case on' in ~/.inputrc (see http://www.cygwin.com/cygwin-ug-net/setup-files.html)
shopt -s nocaseglob
#
# Have less handle unicode (avoids reverse video display of hex, such as for non-breaking space U+FEFF)
export LESSCHARSET=utf-8
# Also have it display binary characters  as underline instead of reverse video (i.e., standout)
export LESSBINFMT="*u<%02X>"

# Don't enable default .bashrc settings
cond-export SKIP_DEFAULT_BASHRC 1
# Don't enable tab completion (n.b., due to slow init)
cond-export SKIP_TAB_COMPLETION 1

# Get idiosyncratic aliases
conditional-source "$TOM_BIN/tomohara-proper-aliases.bash"

# User-specific mount directory
cond-export MNT /media/"$USER"

# Emacs stuff
# use emacs with crontab
## TODO: export EDITOR="emacs -nw"
export EDITOR="emacs"

# Linux stuff
if [ "$(under-linux)" = "1" ]; then
    cond-export WNSEARCHDIR /usr/share/wordnet
fi
