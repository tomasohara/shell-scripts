#! /bin/csh -f
#
# cmd.sh: run's the specified command, capturing stderr and allowing for
# an optional time out
# TODO:
# - get redirection to work with time-outs
# - use timeout command if available
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

# Parse command-line arguments
set command = ""
set use_time_out = 0
set time_out = 30
set time_out_specified = 0
set redirect = 1
set detailed = 0
set log_file = "/tmp/temp_$$.log"
set temp_log = 1

set show_usage = "0"
if ("$1" == "") set show_usage = "1"
while ("$1" =~ -*)
    if ("$1" == "--time-out") then
	set use_time_out = 1
	if ("$2" =~ [0-9]*) then
	    set time_out = $2
	    set time_out_specified = 1
	    shift
	endif
	set redirect = 0
    else if ("$1" == "--redirect") then
	set redirect = 1
    else if ("$1" == "--out-file") then
	set log_file = "$2"
	set temp_log = 0
	shift
    else if ("$1" == "--verbose") then
	set detailed = 1
    else if ("$1" == "--trace") then
	set echo = 1
    else
	set show_usage=1
	echo "Error: unexpected option: $1"
    endif
    shift
end
set command = "$*"

# Show usage if requested or issue with command line
if ("$show_usage" != "0") then
    set script_name = `basename $0`
    echo ""
    echo "usage: `basename $0` [--verbose] [--time-out [N]] [--redirect] [--out-file F] command args ..."
    echo ""
    echo "ex: `basename $0` --time-out 5 prep.exe access.txt"
    echo ""
    exit
endif

# Clear log file
## OLD: set log_file = "/tmp/temp_$$.log"
if (($redirect == 1) || ($use_time_out == 1)) then
    echo "" > "$log_file"
endif

# Setup process to kill the script if timeout occurs
# TODO: figure out how to disable the shells PID display with background jobs
# example: rup.sh wb2
#     [1] 1983
# TODO: rework to kill the child process (e.g., 1983), waiting for it with bash's 'wait PID' or a CSH equivalent
if ($use_time_out == 1) then
    set force_option = ""
    if ( "`printenv OSTYPE`" == "cygwin" ) set force_option = "-f"
    if ($detailed == 1) then
	## OLD: echo "Issuing: (sleep $time_out ... kill $force_option -9 $$) &" >> "$log_file"
	echo "Issuing: (sleep $time_out ... kill $force_option -9 $$) &"
    endif
    ( (sleep $time_out; kill $force_option -9 $$) & ) >& /dev/null
endif

# Run the command redirecting the output
# NOTE: redirection doesn't work with time-out's since the script gets killed
if ($redirect == 1) then
    if ($detailed == 1) then
	## OLD: echo "Issuing: $command" >>&! "$log_file"
	echo "Issuing: $command"
    endif
    ## DEBUG:
    ## set echo=1
    ## $command
    $command >>&! "$log_file"
    if ($temp_log == 1) then
	cat "$log_file"
	rm "$log_file"
    else
	echo "See $log_file for output"
    endif
else
    if ($detailed == 1) then
	echo "Issuing: $command"
    endif
    $command
endif
