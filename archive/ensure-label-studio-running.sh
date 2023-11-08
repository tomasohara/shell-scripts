#!/usr/bin/env bash
#/home/tomohara/bin/ensure-label-studio-running.bash
# Ensures Label Studio is running, re-invoking if necessary.
#
# Notes:
# - Based on script for restarting WiFi service when down
#      https://askubuntu.com/questions/4037/automatically-reconnect-wireless-connection
# - Current process check
#   $ ps auxgww | grep -i label-studio | grep -v port
#   sa_1137+  8256  0.0  4.6 2181652 376440 ?      Sl   Sep27  11:54 /home/sa_113791843099043485579/anaconda3/bin/python /home/sa_113791843099043485579/anaconda3/bin/label-studio start --log-level DEBUG --no-browser
# - Current invocation (uses same directory as settings):
#   cd /home/sa_113791843099043485579/.local/share/label-studio
#   today=$(date '+%d%b%y'); label-studio start --log-level DEBUG --no-browser >> _run-$today.log 2>&1
# - crontab format and example [based on CRONTAB(5), web searching, etc.]:
#     min  hour  day-of-month  month  day-of-week   command
#      0    5        *           *       sun        tar -zcf /var/backups/home.tgz /home/
#   This invokes tar every Sunday at 12:05am.
#
#................................................................................
# Usage example:
# 1. Copy this script into system directory:
#    sudo cp -ivp ensure-label-studio-running.sh /usr/local/bin
#
# 2. Change permissions:
#    sudo chmod +x /usr/local/bin/ensure-label-studio-running.sh 
#
# 3. Add to cron as root
#    sudo crontab -e
#
#       # check Label Studio every hour (on the hour)
#       0 * * * * /usr/local/bin/ensure-label-studio-running.sh 
#

# Check args
show_usage="0"
verbose="0"
sqlite3="0"
port=""
## TODO: debug="1"
debug="0"
while [ "$1" != "" ]; do
    case "$1" in
        --help)
            show_usage=1      ;;
        --trace)
            set -o xtrace     ;;
        --debug)
            debug="1"         ;;
        --non-debug)
            debug="0"         ;;
        --trace)
            set -o xtrace     ;;
        --verbose)
            verbose="1"       ;;
        --sqlite3)
            sqlite3="1"       ;;
        --postgresql)
            sqlite3="0"       ;;
        --port)
            port="$2";
            shift;
            ;;
        *)
            echo "Error: unknown option '$1'";
            show_usage=1;;
    esac
    shift
done
#
script_base=$(basename "$0" .sh)
if [ "$show_usage" = "1" ]; then
    echo ""
    echo "Usage: $0 [--verbose] [--sqllite3 | --postgresql] [--port NNNN] [--debug | --non-debug] [--trace] [--help] [--]"
    echo ""
    echo "Examples:"
    echo "- $script_base.sh --verbose"
    echo ""
    echo "- $script_base.sh --port 8081"
    echo ""
    echo "Notes:"
    echo "- This should be run under the service account (sa_113791843099043485579)"
    echo "- The default port is 8080."
    echo "- Use debug to set debug-level logging"
    echo ""
    exit
fi

# Initialize
if [ "$TMP" = "" ]; then TMP=/tmp; fi
log_file="$TMP/$script_base.log"
temp_file="$TMP/$script_base-$$-1.list"

# Check status and restart if necessary
# NOTE: ignores instances running on non-default port (i.e., port specified)
# TODO: restrict to current user; try recording the process ID in a file and checking that
if [ $"port" != "" ]; then
    ps auxgww | grep --ignore-case "python.*label-studio.*start.*$port" > "$temp_file"
else
    ps auxgww | grep --ignore-case 'python.*label-studio.*start' > "$temp_file"
fi
process_info=$(grep --invert-match --extended-regexp 'port|grep' "$temp_file")
if [ "$process_info" == "" ]; then

    # Restart and issue status
    # Note: Disables following warnings from anal retentive shellcheck
    # - SC2009: Consider using pgrep instead of grepping ps output.
    # - SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
    # shellcheck disable=SC2009,SC2164
    date_yyyy_mm_dd=$(date '+%Y-%m-%d')
    cd "$HOME/.local/share/label-studio"
    misc_args="--no-browser"
    if [ "$debug" = "1" ]; then misc_args="$misc_args --log-level DEBUG"; fi
    if [ "$port" != "" ]; then misc_args="$misc_args --port $port"; fi
    
    if [ "$sqlite3" = "1" ]; then
        if [ "$verbose" = "1" ]; then echo starting Label Studio with sqlite3; fi
        label-studio start "$misc_args" >> "_run-$date_yyyy_mm_dd.log" 2>&1 &
    else
        if [ "$verbose" = "1" ]; then echo starting Label Studio with postgresql; fi

        export DJANGO_DB=default                  \
           POSTGRE_NAME=postgres                  \
           POSTGRE_USER=postgres                  \
           POSTGRE_PASSWORD='r2*ka8sDc@f8'        \
           POSTGRE_PORT=5432                      \
           POSTGRE_HOST=10.1.14.3
 
        label-studio start --database postgresql "$misc_args" >> "_run-$date_yyyy_mm_dd.log" 2>&1 &
        
    fi
    /bin/echo "$(date): Label Studio was restarted (see $PWD/_run-$date_yyyy_mm_dd.log)" >> "$log_file"
#    
elif [ "$verbose" = "1" ]; then

    # Report that OK, showing info from ps
    /bin/echo "$(date): Label Studio is ok" >> "$log_file"
    /bin/echo "    $process_info" >> "$log_file"
    echo "presumably OK:"
    echo "$process_info"
#
else
    
    # TODO: use proper no-op
    echo
fi
