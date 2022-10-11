# idiosyncratic settings for user tomohara
#
# note:
# - New place for settings previously put in tomohara-aliases.bash.
# TODO:
# - ** Move misc. settings from .bashrc and tomohara-aliases.bash here.
# - Flesh out.
#

## OLD: prepend-path "$HOME/python/Mezcla/mezcla"
add-python-path $HOME/python/Mezcla/mezcla
append-path "$HOME/mezcla-tom/examples:$HOME/python/examples:$TOM_BIN/bruno"

# HACK: make sure ~/mezcla-tom used if available
if [ -e "$HOME/mezcla-tom" ]; then add-python-path $HOME/mezcla-tom; fi

# Enable timestamp preservation during git-update alias operations (n.b., stash pop quirk)
export PRESERVE_GIT_STASH=1

# Misc bash options
# make file globs cases insensitve
# note: also include 'set completion-ignore-case on' in ~/.inputrc (see http://www.cygwin.com/cygwin-ug-net/setup-files.html)
shopt -s nocaseglob

# Don't enable default .bashrc settings
cond-export SKIP_DEFAULT_BASHRC 1
# Don't enable tab completion (n.b., due to slow init)
cond-export SKIP_TAB_COMPLETION 1

# Get idiosyncratic aliases
conditional-source "$TOM_BIN/tomohara-proper-aliases.bash"

# User-specific mount directory
cond-export MNT /media/$USER
