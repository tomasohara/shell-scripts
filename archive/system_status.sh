#! /bin/csh -f
#
# system_status.sh: Show system usage statistics
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

# Parse command-line arguments
set verbose_mode=0
set show_env=0
if ("$1" == "") then
    set script_name = `basename $0`
    echo ""
    echo "usage: `basename $0` [--verbose] [--env] [-]"
    echo ""
    echo "ex: `basename $0` --verbose"
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "--verbose") then
        set verbose_mode=1
    else if ("$1" == "--env") then
        set show_env=1
    else if ("$1" == "-") then
	# - is just used to bypass the usage message
        :
    else
        echo "unknown option: $1"
    endif
    shift
end

# Display system identification info
uname -a

# Show available memory
if ($OSTYPE == "linux") then
    free
else
    # TODO: figure out how to show memory stats under solaris
    :
endif

# Show who is on the system
## uptime
w
echo ""

# Show active processes
if ($verbose_mode) then
    if ($OSTYPE == "linux") then

	top n 1 b
    else

	perl ps_sort.perl -num_times=1 -
    endif
    echo ""
endif

# Show free disk space
# TODO: include a time-out check
if ($verbose_mode) then
    df
    echo ""
endif

# Print the environment settings
if ($show_env) then
    printenv
    echo ""
endif

