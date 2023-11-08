#! /bin/csh -f
#
# rsh.sh: wrapper around rsh which includes a time-out check
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1
## echo This job has PID $$
## ps_mine.sh | grep rsh

# Parse command-line arguments
set use_time_out = "1"
set time_out = 30
set time_out_specified = 0
set rsh_options = ""
set background_option = "-n"
set rsh = "rsh"

# Show usage statement if no arguments given
if ("$1" == "") then
    set script_name = `basename $0`
    echo ""
    echo "usage: `basename $0` [--time-out [N]] [--skip-time-out] [--ssh]"
    echo ""
    echo "ex: `basename $0` whatever"
    echo ""
    exit
endif

# Parse command-line arguments
while ("$1" =~ -*)
    if ("$1" == "--time-out") then
	set use_time_out = 1
	if ("$2" =~ [0-9]*) then
	    set time_out = $2
	    set time_out_specified = 1
	    shift
	endif
    else if ("$1" == "--skip-time-out") then
	set use_time_out = 0
    else if ("$1" == "--ssh") then
	set rsh = "ssh"
	## set background_option = "-f"
	# TODO: figure out problem w/ -n and -f options leading to no output
	set background_option = ""
    else if ("$1" =~ --*) then
	echo "ERROR: unknown argument '$1'
	exit
    else
	set rsh_options = "$rsh_options $1"
    endif
    shift
end
set host = "$1"
shift
set command = "$*"

# Setup process to kill the script if timeout occurs
# TODO: figure out how to disable the shells PID display with background jobs
# ex: rsh.sh wb2
#     [1] 1983
if ($use_time_out) then
    ( (sleep $time_out; kill -9 $$) & ) >& /dev/null
endif

# If no command given do interactive rsh
if ("$command"  == "") then
    $rsh $host

# Othersise execute the command with output redirected
else 
    set temp_log = /tmp/temp_rsh_$$.log
    $rsh $background_option $rsh_options $host $command >&! $temp_log

    # Show the output
    cat ${temp_log}
    rm ${temp_log}
endif

