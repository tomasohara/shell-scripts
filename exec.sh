#!/bin/csh -f

# execute the command on the default host

# set echo=1

    set dir = ~/tpo
    if ($1 != "") then 
        set dir = $1
	shift
    endif

    # If the only argument is for a directory, use the default remote
    # host (eg, corinth), rather than the current host (eg, pylos).
    if ($?DEFAULT_HOST == 0) setenv DEFAULT_HOST $HOST
    if (-e ~/.default_host) setenv DEFAULT_HOST `cat ~/.default_host`
    if (($DEFAULT_HOST != $HOST) && ("$1" == "")) then
	echo  $dir > ~/.current_directory
	xterm -T ${DEFAULT_HOST}:${dir} -e rlogin.sh $DEFAULT_HOST &
    else
	cd $dir
	xterm -T $dir $* &
    endif
