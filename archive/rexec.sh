#! /bin/csh -f
#
# A roundabout way of doing a remote command execution. To support
# running interactive jobs on remote hosts (which rsh doesn't allow)
# a remote login is made to execute the command. To handle this
# the command is written to a file prior to the remote login. Then
# the .login script executes the command in the background and
# immediately logs out.
#
# TODO: let .default_host override DEFAULT_HOST

if ("$1" == "") then
    echo "usage: rexec.sh host command arg ..."
    exit
endif
set host = $1
shift

if ("$host" == "-") then
    if ($?DEFAULT_HOST == 0) setenv DEFAULT_HOST $HOST
    if (-e ~/.default_host) setenv DEFAULT_HOST `cat ~/.default_host`
    set host = $DEFAULT_HOST
endif

# Revise the DISPLAY variable to reflect the host
if ($?DISPLAY) then
    if ($DISPLAY == ":0.0") setenv DISPLAY ${HOST}:0.0
endif

# Set the parameter-files .current_display and .current_command interpreted
# by .login
#
if (-w ~/.current_display) then
    printenv DISPLAY > ~/.current_display
endif
echo $* >! ~/.current_command

# Do a remote login, which will just execute the command and then logout
#
xhost +$host
rlogin $host

# Attempt to fix the terminal settings
#
resize
