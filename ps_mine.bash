#! /usr/bin/env bash
#
# ps_mine.sh: show processes belonging to a particular user
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
# - Under Linux, dashes for the command options are deprecated:
# ps -auxwww 
# ...
#    warning: `-' deprecated; use `ps auxwww', not `ps -auxwww'
# - Converted from csh version by POE Assistant (GPT-4o?).
#
# TODO:
# - Have option to duplicate headers at end.
# - *** Optionally make the filters case insensitive.
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
if [ "${DEBUG_LEVEL:-0}" -ge 4 ]; then
    echo "$0 $*"
fi
if [[ "${TRACE:-0}" == "1" ]]; then
    set -o xtrace
fi
if [[ "${VERBOSE:-0}" == "1" ]]; then
    set -o verbose
fi
if [[ -z "${DEBUG_LEVEL}" ]]; then DEBUG_LEVEL=0; fi

user=$(whoami)
verbose_mode=0
exclude_filter='($)(^)' # exclude nothing (i.e., unsatisfiable regex)
include_filter='.'      # include everything

# Help message
if [[ "$1" == "-?" || "$*" =~ -h || "$*" =~ --help ]]; then
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
fi

# Parse options
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        --all|-a)
            user=""
            ;;
        --user|-u)
            user="$2"
            shift
            ;;
        --filtered)
            # NOTE: -csh likely used for relics running csh-based scripts
            if [[ $DEBUG_LEVEL -ge 3 ]]; then
                echo "FYI: filtering entries (e.g., misc. bash and csh processes)"
            fi
            exclude_filter='([-]csh|(csh.*ps_mine.sh)|<defunct>)'
            ;;
        --verbose|-v)
            verbose_mode=1
            ;;
        --trace)
            set -x
            ;;
        *)
            echo "Unrecognized option: $1"
            ;;
    esac
    shift
done

if [[ -n "$*" ]]; then
    include_filter="$*"
fi

# Show some host statistics if verbose output desired
if [[ $verbose_mode -eq 1 ]]; then
    uname -a
    uptime
fi

# Determine the process-listing command to use as well as the sort fields
# Note: ps options (BSD): a[ll]; u[ser]; g[roup]; w[ide] output (ww unlimited)
# via ps man page:
#     a  Lift the BSD-style "only yourself" restriction[.]
#     g  Really all, even session leaders.  This flag is obsolete and may be
#        discontinued in a future release.  It is normally implied by the a
#        flag, and is only useful when operating in the sunos4 personality.
#     w  Wide output.  Use this option twice for unlimited width.
ps_command="ps auxww"
# TODO: break down into grep_command and grep_options (see HACK below)
grep_command="grep '^$user'"
sort_command="sort --key=3 --key=4 -rn"
egrep="egrep"

if [[ "$OSTYPE" == "solaris"* ]]; then
    ps_command="ps -ef"
    grep_command="egrep -i '^ +$user'"
    sort_command="sort --key=3 -rn"
else
    egrep="grep --extended-regexp"
fi

# Show optional status
if [[ $verbose_mode -eq 1 ]]; then
    echo "Issuing: $ps_command | $grep_command | $egrep -v '$exclude_filter' | $egrep '$include_filter' | $sort_command"
fi

# Display header
$ps_command | head -1

# Display the processes sorted by CPU usage
# NOTE: ps output first written to an output file so that grep and sort commands not listed
TMP="${TMP:-/tmp}"
ps_output="/tmp/ps_$$.list"
$ps_command | tail -n +2 > "$ps_output"

if [[ "$OSTYPE" == "solaris"* ]]; then
    # TODO: fix stupid problem with grep under Solaris ("No match" reported but OK interactively issuing the same command)
    grep "^ *$user" "$ps_output" | $egrep -v "$exclude_filter" | $egrep "$include_filter" | grep -v "$ps_command" | $sort_command
else
    # HACK
    grep "^$user" "$ps_output" | $egrep -i -v "$exclude_filter" | $egrep -i "$include_filter" | grep -i -v "$ps_command" | $sort_command
fi

# Cleanup
if [[ $DEBUG_LEVEL -lt 4 ]]; then
    rm "$ps_output"
fi
