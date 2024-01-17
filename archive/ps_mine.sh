#! /usr/bin/env csh
## BAD: #! /bin/csh -f
#
# ps_mine.sh: show processes belonging to particular user
# note: the processes are shown sorted by CPU and then by memory
#
# sample ps output:
#
# USER       PID %CPU %MEM   VSZ  RSS TTY      STAT START   TIME COMMAND
# root         1  0.0  0.0   444   68 ?        S    Aug06   0:04 init [3]
# root         2  0.0  0.0     0    0 ?        SW   Aug06   0:00 [keventd]
# root         3  0.0  0.0     0    0 ?        SWN  Aug06   0:00 [ksoftirqd_CPU0]
# root         4  0.0  0.0     0    0 ?        SW   Aug06   0:00 [kswapd]
# ...
# tomohara 20529  0.0  0.6  2516 1608 pts/0    S    15:39   0:00 bash
# root     20565  0.0  0.5  2616 1384 ?        S    15:39   0:01 /usr/sbin/sshd
# tomohara 20568  0.0  0.5  2320 1436 pts/1    S    15:39   0:00 bash
# tomohara 20596  0.0  0.5  2684 1380 pts/1    S    15:39   0:00 ssh medusa
# root     20633  0.0  0.5  2616 1380 ?        S    15:46   0:00 /usr/sbin/sshd
# tomohara 20636  0.0  0.5  2388 1528 pts/2    S    15:46   0:00 bash
# root     20693  0.0  0.5  2632 1396 ?        S    15:47   0:00 /usr/sbin/sshd
# ...
#
# Notes:
#
# Under Linux, dashes for the command options are deprecated:
# ps -auxwww 
# ...
#    warning: `-' deprecated; use `ps auxwww', not `ps -auxwww'
#
# TODO:
# - Have option to duplicate headers at end.
# - *** Optionally make the filters case insensitive.
# - ** Cleanup source (remove comments flagged with OLD).
#


# Uncomment (or comment) the following for enabling (or disabling) tracing
## DEBUG: set echo=1
if ($?DEBUG_LEVEL == 0) set DEBUG_LEVEL=0

set user = `whoami`
set verbose_mode = 0
set exclude_filter = '($)(^)'		# exclude nothing (i.e., unsatisfiable regex)
set include_filter = '.'                # include everything
if (("$1" == "-?") || ("$*" =~ *-h*) || ("$*" =~ *--help*)) then
    echo ""
    echo "Usage: $0 [--all | -a] [--verbose | -v] [--user name] [--filtered] [pattern]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0"
    echo ""
    echo "$0 --all | grep -v root"
    echo ""
    echo "foreach.perl -remote -busy_load=0 '$0 --verbose' >| my_remote_processes.log 2>&1"
    echo ""
    echo "Notes:"
    echo "- The --filtered option ignores bash csh and defunct processes."
    echo "- The optional pattern augments the filter."
    echo "- The --verbose option shows command execution and some host stats (e.g., uptime)."
    echo "- The --trace option shows detailed Bash interpreter tracing."
    exit
endif
while ("$1" =~ -*) 
    if (("$1" == "--all") || ("$1" == "-a")) then
	set user = ""
    else if (("$1" == "--user") || ("$1" == "-u")) then
	set user = "$2"
	shift
    else if ("$1" == "--filtered") then
        ## NOTE: -csh likely used for relics running csh-based scripts
        if ($DEBUG_LEVEL >= 3) echo "FYI: filtering entries (e.g., misc. bash and csh processes)"
	set exclude_filter = '((bash *$)|\-csh|(csh.*ps_mine.sh)|<defunct>)'
        set exclude_filter = '(\-csh|(csh.*ps_mine.sh)|<defunct>)'
    else if (("$1" == "--verbose") || ("$1" == "-v")) then
	set verbose_mode = 1
    else if ("$1" == "--trace") then
	set echo = 1
    else 
	echo "Unrecognized option: $1"
    endif
    shift
end
if ("$argv" != "") then
    set include_filter="$argv"
endif

# Show some host statistics if verbose output desired
if ($verbose_mode) then
    uname -a
    uptime
endif

# Determine the process-listing command to use as well as the sort fields
# Note: ps options (BSD): a[ll]; u[ser]; g[roup]; w[ide] output (ww unlimited)
# via ps man page:
#     a  Lift the BSD-style "only yourself" restriction[.]
#     g  Really all, even session leaders.  This flag is obsolete and may be
#        discontinued in a future release.  It is normally implied by the a
#        flag, and is only useful when operating in the sunos4 personality.
#     w  Wide output.  Use this option twice for unlimited width.
#     x  Lift the BSD-style "must have a tty" restriction[.]
set ps_command = "ps auxww"
## TODO: break down into grep_command and grep_options (see HACK below)
set grep_command = "grep '^$user'"
set sort_command = "sort --key=3 --key=4 -rn"
if ($OSTYPE == solaris) then
    set ps_command = "ps -ef"
    set grep_command = "egrep -i '^ +$user'"
    set sort_command = "sort --key=3 -rn"
endif
    

# Show optional status
if ($verbose_mode) then
    echo "Issuing: $ps_command | $grep_command | egrep -v '$exclude_filter' | egrep '$include_filter' | $sort_command"
endif

# Display header
$ps_command | head -1

# Display the processes sorted by cpu usage
# NOTE: ps output first written to an output file  so that grep and sort commands not listed
set ps_output = /tmp/ps_$$.list
$ps_command | tail --line=+2 > $ps_output
if ($OSTYPE == solaris) then
    # TODO: fix stupid problem with grep under Solaris ("No match" reported but OK interactively issuing same command)
    grep "^ *$user" $ps_output | egrep -v "$exclude_filter" | egrep "$include_filter" | grep -v "$ps_command" | $sort_command
    ## grep "^ *$user" $ps_output | $sort_command
else
    ## HACK
    grep "^$user" $ps_output | egrep -i -v "$exclude_filter" | egrep -i "$include_filter" | grep -i -v "$ps_command" | $sort_command
endif

# Cleanup
rm $ps_output

## TODO: delete
## dummy change for git
