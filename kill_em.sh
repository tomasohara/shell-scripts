#!/bin/csh -f
#
# kill_em.sh: script for killing processes specified by name or pattern.
# In addition, there is special support for killing graphling processed
#
# Note:
# - This greps through the ps output for a specified pattern (e.g., python).
# - Sample ps output:
#   USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
#   root         1  0.0  0.0 139604  7268 ?        Ss   Jan02   0:19 /sbin/init
#   root         2  0.0  0.0      0     0 ?        S    Jan02   0:00 [kthreadd]
#
#
# TODO:
# - separate out the Graphling support into a new script just for that
# - figure out occasional problem with graphling files not getting deleted after processed killed

# Uncomemnt the following line for tracing
# set echo=1

# Initialize options and variables
# NOTE: temp file is of the form /tmp/kill_em_aux_HOSTNAME_PID
# TODO: use $TEMP for /tmp
set host=`hostname`
set aux_base=/tmp/kill_em_aux_$host.$$
set aux_script=$aux_base.sh
set aux_file0=$aux_base.lst0
set aux_file1=$aux_base.lst1
# Note: by default requires number [from time] prior to process spec.
set pattern_prefix = "[0-9] [^ ]*"
set filter = '($)(^)'		# filters nothing (i.e., unsatisfiable regex)
set user = `whoami`
## OLD:
## set graphling = 0
## set copy_result = 0
set test = 0
set verbose_mode = 0
set command_line = "$0 $argv"

# Parse command-line arguments
set ignore = "-i"		# ignore-case flag
set script_name = `basename $0`
if ("$1" == "") then
    echo ""
    echo "Usage: $0 options [process_name]"
    echo ""
    ## OLD: echo "Options: [--pattern|-p] [--filter pattern] [--ignore-case] [--preserve-case|-i-] [--all] [--graphling [--copy]] [--test] [--verbose]"
    echo "Options: [--pattern | -p] [--filter pattern] [--ignore-case | -i-] [--preserve-case] [--user id] [--all | -a] [--test] [--verbose] [--trace]"
    echo ""
    echo "notes:"
    echo "- The --pattern (-p) option treats process_name as regex for egrep."
    echo "- The --filter specifies likwise filters via an egrep regex."
    echo "- The --preserve-case (-i-) option disables case insensitive search (default)."
    echo "- The --test patterns shows which processes will be killed."
    ## echo "- The --graphling and --copy options are deprecated."
    echo "- The --user option specifies owning username for processes to kill."
    echo "- The --all option includes processes for all users."
    echo "- The --verbose options displays progress output."
    echo "- The --trace options shows commands to be executed (via csh echo=1)."
    echo ""
    echo "Examples:"
    echo ""
    echo "$script_name --pattern firefox"
    echo ""
    echo "$script_name --test python --filter ipython"
    echo ""
    ## OLD: echo "foreach.perl -busy_load=0 -remote -d=4 '$0 --graphling' >| kill_all.log 2>&1"
    echo "foreach.perl -busy_load=0 -remote -d=4 '$0 --pattern my_mrjob' >| kill-all-my-mrjob-processes.log 2>&1"
    echo ""
    exit
endif
while ("$1" =~ -*)  
    if (("$1" == "--pattern") || ("$1" == "-p")) then
        set pattern_prefix = ""
    else if ("$1" == "--filter") then
        set filter = "$2"
        shift
    else if (("$1" == "--ignore-case") || ("$1" == "-p")) then
        set ignore = ""
    else if (("$1" == "--preserves-case") || ("$1" == "-i-")) then
        set ignore = "-i-"
    ## OLD:
    ## else if ("$1" =~ --graph*) then
    ##     set graphling = 1
    ##     # Kill jobs with SAMPLE(ALL) or GRAPH_LING or graphling in command line
    ##     set pattern_prefix = "(SAMPLE)|(GRAPH_LING)|(graphling)"
    else if ("$1" == "--copy") then
        set copy_result = 1
    else if ("$1" =~ --user) then
	set user = "$2"
	shift
    else if ("$1" == "--trace") then
        set echo=1
    else if ("$1" == "--verbose") then
        set verbose_mode=1
	echo "command: $command_line"
    else if ("$1" == "--test") then
        set test = 1
	echo "command: $command_line"
    ## OLD: else if ("$1" == "--all") then
    else if (("$1" == "--all") || ("$1" == "-a")) then
        # HACK: set username as regex to match all users
	# via https://unix.stackexchange.com/questions/157426/what-is-the-regex-to-validate-linux-users
	## OLD: set user="[a-z][a-z]*"
        ## TODO: support usernames ending in $
        ## BAD: set user="[a-z_][a-z0-9_-]*[\\$]?"
        set user="[a-z_][a-z0-9_-]*"
    ## OLD: else if (("$1" == "-a") || ("$1" == "--all")) then
        ## OLD: set pattern_prefix = "."
	set pattern_prefix = ".*"
    else
        echo "Error: Unrecognized argument: $1"
        exit
    endif
    shift
end
set pattern = "${pattern_prefix}$*"
echo "pattern=/$pattern/"
echo "filter=/$filter/"

# Determine the processes for the user.
# This is optionally restricted to the pattern (by default case insensitive)
set options = "auxww"
# NOTE: the ps command itself is filtered out since not active later
if ($OSTYPE == solaris) set options = "-ef"
## OLD: ps $options | grep "^ *$user" | egrep -v "\bps $options\b" | egrep -v "\b$$\b" | egrep -v "$filter" | egrep $ignore "$pattern" > $aux_file0
ps $options | egrep "^ *$user" | egrep -v "\bps $options\b" | egrep -v "\b$$\b" | egrep -v "$filter" | egrep $ignore "$pattern" > $aux_file0
if ("$verbose_mode" == "1") then
    echo "Candidate processes (prior to parent and current script filtering)"
    cat $aux_file0
endif


# If all processes to be killed (for the user, exclude the current processes
# for this script as well as the parent process (e.g., the shell). This is
# intended for remote execution.
#
# NOTES:
#  $ ps alwx | egrep "(PID|$$)"
#    F   UID   PID  PPID PRI  NI   VSZ  RSS WCHAN  STAT TTY        TIME COMMAND
#  100  2222 31510 31507  18   0  2568 1708 wait4  S    pts/1      0:00 bash
#  000  2222 31656 31510  18   0  3528 1532 -      R    pts/1      0:00 ps alwx
#  000  2222 31657 31510  18   0  1404  460 pipe_w S    pts/1      0:00 egrep (PID|31510)
#   
if ("$pattern" == ".") then
    set parent=`ps alwx | perl -Ssw extract_matches.perl "^\d+\s+\d+\s+$$\s+(\d+)"`
    if ("$parent" == "") then
	echo "ERROR: unable to determine parent pid"
	exit
    endif
    egrep -v "(egrep )|(kill_em.sh )|($$)|($parent)" $aux_file0 > $aux_file1
    if ("$verbose_mode" == "1") then
	echo "Related processes"
	cat $aux_file1
    endif
else
    cp $aux_file0 $aux_file1
endif

# Do sanity check on processes to kill
if (-z $aux_file1) then
    echo "ERROR: No processes matched the pattern"
    exit
endif

# Convert the process listing to a shell script for killing the jobs. The
# jobs are killed in process ID order so that the processes for this job 
# are killed last (see previous TODO).
#    perl options: -00 EOF as separator; -n loop through lines; -e expression
echo "processes:"
cat $aux_file1
## OLD: sed -e "s/^ *$user *//g" < $aux_file1 | sed -e 's/ .*//g' | grep -v '^ *$' | sort -n | perl -00 -n -e 's/\n/ /g; s/^/kill -9 /; print "$_\n";' > $aux_script
perl -pe "s/^ *$user *//g;" < $aux_file1 | sed -e 's/ .*//g' | egrep -v '^ *$' | sort -n | perl -00 -n -e 's/\n/ /g; s/^/kill -9 /; print "$_\n";' > $aux_script
if ($test == 1) then
    perl -i.bak -pe 's/^/echo /;' $aux_script
endif

# Do sanity check on kill script
if (-z $aux_script) then
    echo "ERROR: Problem preparing aux script for killing processes."
    exit
endif

# Execute the kill script after showing the processes to be killed
cat $aux_script
source $aux_script

## OLD: This was a relic of NMSU version.
## # Do special GraphLing-related cleanup, including removing the temporary
## # files after optionally copying the result to the graphling directory.
## #
## # Note: Temporary files are normally placed in /tmp. But for the CS
## # parallel nodes (wb1 .. wb32) they are palced in /local/tmp
## if ($graphling) then
##     df
##     echo "Removing files in /tmp/graphling.* and /local/tmp/graphling.*"
##     ls -l /tmp/graphling.* /local/tmp/graphling.*
##     if ($copy_result) then
## 	cp -r -p -f /tmp/graphling.*/* /local/tmp/graphling.*/* /home/graphling/TEMP
##     endif
## 
##     # Remove the temporary GraphLing files that belong to the current user
##     ls -ltd /tmp/graphling.* /local/tmp/graphling.* /tmp/CoCo.* | egrep "$USER" | sed -e "s/.* /rm -r /" > /tmp/rm_graphling.sh
##     source /tmp/rm_graphling.sh
##     rm /tmp/rm_graphling.sh
## endif

# Cleanup things
if ($?DEBUG_LEVEL == 0) set DEBUG_LEVEL=0
if ($DEBUG_LEVEL < 5) rm $aux_base*
