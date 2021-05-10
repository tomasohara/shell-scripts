#! /usr/csh -f
#
# login_misc.sh: miscellaneous login "hooks"
#
# usage: source login_misc.sh (from .login of course)
#

# Uncomment the following for .login/.cshrc tracing
# TODO: use an alias arounda conditional echo command
startup-trace in login_misc.sh

#-----------------------------------------------------------------------------
# Check for various login "parameters" contained in certain files
#	.current_display	DISPLAY host to use
#	.current_directory	directory for the login shell
#	.current_command	command to issue (and then logout)

# Set the DISPLAY to the value from .current_display, which rlogin.sh
# creates. Afterwards, rename the file so it doesn't become stale, unless
# it is read-only, in which case it is treated as permanent.
#
if (-e ~/.current_display) then
    setenv DISPLAY `cat ~/.current_display`
    echo DISPLAY set to $DISPLAY
    if (-w "~/.current_display") /bin/mv -f ~/.current_display ~/.old_current_display
endif
startup-trace after current display check

# Set the current directory from .current_directory, which xterm.sh
# creates in order to support DEFAULT_HOST-based override's for fvwm directory 
# menu items (eg, Left_button -> graphling invokes rlogin.sh to corinth
# with the current directory set to ~/GRAPH_LING).
#
if (-e ~/.current_directory) then
    set current_directory = `cat ~/.current_directory`
    /bin/mv -f ~/.current_directory ~/.old_current_directory
    echo Setting current directory to $current_directory
    cd $current_directory
endif
startup-trace after current directory check

# Issue the command contained in .current_command and then logout
# afterwards. The command is run in the background. This is mainly intended
# to support remote execution of interactive commands like Netscape.
#
if (-e ~/.current_command) then
    set current_command = `cat ~/.current_command`
    /bin/mv -f ~/.current_command ~/.old_current_command
    echo Executing $current_command
    $current_command &
    logout
endif
startup-trace after current command check

# Resize the xterm and invoke cd alias to display current directory in title
if ($?tty == 0) set tty = "console"
if ($tty != "console") then
    # resize > /dev/null
    cd .
endif
startup-trace after console check

# Optional end tracing
startup-trace out login_misc.sh
