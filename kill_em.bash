#!/bin/bash
#
# translation of kill_em.sh into bash via ChatGPT and manual revision
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

# Uncomment the following line for tracing
# set -x

# Initialize options and variables
# NOTE: temp file is of the form /tmp/kill_em_aux_HOSTNAME_PID
# TODO: use $TEMP for /tmp
host=$(hostname)
aux_base="/tmp/kill_em_aux_$host.$$"
aux_script="$aux_base.sh"
aux_file0="$aux_base.lst0"
aux_file1="$aux_base.lst1"
# Note: by default requires number [from time] prior to process spec.
pattern_prefix=":[0-9][0-9] [^ ]*"
filter='($)(^)' # filters nothing (i.e., unsatisfiable regex)
is_root=0
user=$(whoami)
if [ "$user" == "root" ]; then
  is_root=1
fi
test=0
verbose_mode=0
command_line="$0 $*"
force=0

# Parse command-line arguments
ignore="-i" # ignore-case flag
script_name=$(basename "$0")
egrep="egrep"
if [ -z "$1" ]; then
  echo ""
  echo "Usage: $0 options [process_name]"
  echo ""
  echo "Options: [--pattern | -p] [--filter pattern] [--ignore-case | -i-] [--preserve-case] [--user id] [--all | -a] [--test] [--verbose] [--trace] [--force]"
  echo ""
  echo "notes:"
  echo "- The --pattern (-p) option treats process_name as regex for egrep."
  echo "- The --filter specifies likwise filters via an egrep regex."
  echo "- The --preserve-case (-i-) option disables case insensitive search (default)."
  echo "- The --test patterns shows which processes will be killed."
  echo "- The --user option specifies owning username for processes to kill."
  echo "- The --all option includes processes for all users."
  echo "- The --verbose options displays progress output."
  echo "- The --trace options shows commands to be executed (via csh echo=1)."
  echo "- The --force is required if running as root (e.g., via sudo)."
  echo ""
  echo "Examples:"
  echo ""
  echo "$script_name --pattern firefox"
  echo ""
  echo "$script_name --test python --filter ipython"
  echo ""
  echo "foreach.perl -busy_load=0 -remote -d=4 '$0 --pattern my_mrjob' >| kill-all-my-mrjob-processes.log 2>&1"
  echo ""
  exit
fi
while [[ $1 =~ ^-.* ]]; do
  if [ "$1" == "--pattern" ] || [ "$1" == "-p" ]; then
    pattern_prefix=""
  elif [ "$1" == "--filter" ]; then
    filter="$2"
    shift
  elif [ "$1" == "--ignore-case" ] || [ "$1" == "-p" ]; then
    ignore=""
  elif [ "$1" == "--preserves-case" ] || [ "$1" == "-i-" ]; then
    ignore="-i-"
  elif [[ $1 =~ ^--user.* ]]; then
    user="$2"
    shift
  elif [ "$1" == "--trace" ]; then
    set -x
  elif [ "$1" == "--force" ]; then
    force=1
  elif [ "$1" == "--verbose" ]; then
    verbose_mode=1
    echo "command: $command_line"
  elif [ "$1" == "--test" ]; then
    test=1
    echo "command: $command_line"
  elif [ "$1" == "--all" ] || [ "$1" == "-a" ]; then
    # HACK: set username as regex to match all users
    # via https://unix.stackexchange.com/questions/157426/what-is-the-regex-to-validate-linux-users
    ## TODO: support usernames ending in $
    ## NOTE: If user ID too long, it is truncated in the ps listing and a + is appended.
    ## EX: thomas_+ 27423  0.0  0.0  14864  1124 pts/1    S+   19:36   0:00 grep -E -i jupyter
    user="[a-z_][a-z0-9_-+]*"
    if [ "$OSTYPE" == "linux" ]; then
      user="\S+"
      egrep="grep --perl-regexp"
    fi
    pattern_prefix=".*"
  else
    echo "Error: Unrecognized argument: $1"
    exit
  fi
  shift
done
pattern="${pattern_prefix}$*"
echo "pattern=/$pattern/"
echo "filter=/$filter/"
if [ "$is_root" == "1" ] && [ "$force" == "0" ]; then
  echo "Error: The --force option is required if running as root (or via sudo)"
  exit
fi

# Determine the processes for the user.
# This is optionally restricted to the pattern (by default case insensitive)
options="auxww"
# NOTE: the ps command itself is filtered out since not active later
if [ "$OSTYPE" == "solaris" ]; then
  options="-ef"
fi
ps $options | $egrep "^ *$user" | $egrep -v "\bps $options\b" | $egrep -v "\b$$\b" | $egrep -v "$filter" | $egrep $ignore "$pattern" > "$aux_file0"
if [ "$verbose_mode" == "1" ]; then
  echo "Candidate processes (prior to parent and current script filtering)"
  cat "$aux_file0"
fi

# If all processes to be killed (for the user, exclude the current processes
# for this script as well as the parent process (e.g., the shell). This is
# intended for remote execution.
#
# NOTES:
# - example
#   $ ps alwx | egrep "(PID|$$)"
#     F   UID   PID  PPID PRI  NI   VSZ  RSS WCHAN  STAT TTY        TIME COMMAND
#   100  2222 31510 31507  18   0  2568 1708 wait4  S    pts/1      0:00 bash
#   000  2222 31656 31510  18   0  3528 1532 -      R    pts/1      0:00 ps alwx
#   000  2222 31657 31510  18   0  1404  460 pipe_w S    pts/1      0:00 egrep (PID|31510)
# - where a[ll]; l[ong]; w[ide]; and x is for no tty (redundant with 'a')
# - TODO: drop w and x
#
if [ "$pattern" == "." ]; then
  parent=$(ps alwx | perl -Ssw extract_matches.perl "^\d+\s+\d+\s+$$\s+(\d+)")
  if [ -z "$parent" ]; then
    echo "ERROR: unable to determine parent pid"
    exit
  fi
  $egrep -v "(egrep )|(kill_em.sh )|($$)|($parent)" "$aux_file0" > "$aux_file1"
  if [ "$verbose_mode" == "1" ]; then
    echo "Related processes"
    cat "$aux_file1"
  fi
else
  cp "$aux_file0" "$aux_file1"
fi

# Do sanity check on processes to kill
if [ ! -s "$aux_file1" ]; then
  echo "Warning: No processes matched the pattern"
  exit
fi

# Convert the process listing to a shell script for killing the jobs. The
# jobs are killed in process ID order so that the processes for this job 
# are killed last (see previous TODO).
#    perl options: -00 EOF as separator; -n loop through lines; -e expression
echo "processes:"
cat "$aux_file1"
perl -pe "s/^ *$user *//g;" < "$aux_file1" | sed -e 's/ .*//g' | $egrep -v '^ *$' | sort -n | perl -00 -n -e 's/\n/ /g; s/^/kill -9 /; print "$_\n";' > "$aux_script"
if [ $test == 1 ]; then
  perl -i.bak -pe 's/^/echo /;' "$aux_script"
fi

# Do sanity check on kill script
if [ ! -s "$aux_script" ]; then
  echo "ERROR: Problem preparing aux script for killing processes."
  exit
fi

# Execute the kill script after showing the processes to be killed
cat "$aux_script"
source "$aux_script"

# Cleanup things
if [ -z "$DEBUG_LEVEL" ]; then
  DEBUG_LEVEL=0
fi
if [ "$DEBUG_LEVEL" -lt 5 ]; then
  rm "$aux_base"*
fi
