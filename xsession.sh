#! /bin/csh -f
#
# Script for starting a remote xsession. That is to simulate the
# xession environment that would be present on the local machine
# (useful when using a slow machine's console)
#


## xmodmap ~/.xmodmap_sun
## source ~/bin/set_display.sh
if (-e ~/.current_display) then
    setenv DISPLAY `cat ~/.current_display`
    echo DISPLAY set to $DISPLAY
    if (-w "~/.current_display") /bin/mv -f ~/.current_display ~/.old_current_display
endif

source ~/.xsession $*
## xmodmap ~/.xmodmap_sun

