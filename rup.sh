#! /bin/csh -f
#
# rup.sh: simulated rup using uptime. This also uses rup to show the
# connected machines.
#
# TODO:
#    - rename to ruptime.sh to avoid confusion with rup??
#
# NOTES:
#
# - this works around the problem with the rup protocol not being
#   used on local machines
#
# - from rsh man page:
#     -n    The -n option redirects input from the special device /dev/null
#           (see the BUGS section of this manual page).
#
# 
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1
## echo This job has PID $$
## ps_mine.sh | grep rup

# Parse command-line arguments
set use_time_out = "0"
set time_out = 30
set time_out_specified = 0
if ("$1" == "") then
    set script_name = `basename $0`
    echo ""
    echo "usage: `basename $0` [--time-out [N]]"
    echo ""
    echo "ex: `basename $0` --time-out 5 wb1"
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "--time-out") then
	set use_time_out = 1
	if ("$2" =~ [0-9]*) then
	    set time_out = $2
	    set time_out_specified = 1
	    shift
	endif
    else if ("$1" == "-") then
	# - indicates all hosts (as with rup with no arguments)
	if (! $time_out_specified) set time_out = 60
    else
	echo "unknown option: $1"
    endif
    shift
end
set host = "$*"

# Setup process to kill the script if timeout occurs
# TODO: figure out how to disable the shells PID display with background jobs
# ex: rup.sh wb2
#     [1] 1983
if ($use_time_out) then
    ( (sleep $time_out; kill -9 $$) & ) >& /dev/null
endif

# Execute the command with output redirected
set temp_log = /tmp/temp_rup_$$.log
if ("$host" == "") then
    rup >&! ${temp_log}
else
    rsh -n $host uptime >&! ${temp_log}
endif

# Show the output
cat ${temp_log}
rm ${temp_log}
