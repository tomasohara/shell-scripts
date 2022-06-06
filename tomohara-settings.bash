# idiosyncratic settings for user tomohara
#
# note:
# - New place for settings previously put in tomohara-aliases.bash.
# TODO:
# - flesh out
#

## OLD: prepend-path "$HOME/python/Mezcla/mezcla"
add-python-path $HOME/python/Mezcla/mezcla
append-path "$HOME/mezcla-tom/examples:$HOME/python/examples:$TOM_BIN/bruno"

# Enable timestamp preservation during git-update alias operations (n.b., stash pop quirk)
export PRESERVE_GIT_STASH=1
