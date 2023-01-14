#!/bin/bash
#
# Stops an inactive server if there is no significant network or system activity
#
# Note:
# - This is intended for shutting down pricey AWS EC2 instances to keep costs down.
# - Indicator functions like low_network_load output "True" if the condition holds.
# - Any debug tracing in such functions should go to stderr. This can be done as follows:
#    echo "fu=$fu" 1>&2
# - For shellcheck [SC2086: Double quote to prevent globbing and word splitting].
#
# Usage examples:
# 1. Interactive for testing (n.b., sudo required for actual shutdown):
#    stop-inactive-server.bash
#
# 2. Add to cron as root:
#    sudo crontab -e
#
#       # check for inactive server every hour (on the hour) and shutdown if so
#       0 * * * * /usr/local/bin/stop-inactive-server.bash
#
# Script by Tana Alvarez and Tom O'Hara.
#
# TODO:
# - Add checks for missing special files with performance data (e.g., /proc/loadavg):
# - Rework to maintain stats separately so that usable just invoking every few hours,
#   such as by adding mean and stdev checks over specified period.
#

# Initialize
TMP="${TMP:-/tmp}"
VERBOSE="${VERBOSE:-0}"
TRACE="${TRACE:-0}"
LOG="${LOG:-/home/ubuntu/stop-inactive-server.log}"
TIME=$(date)

# Enable debug trace
if [ "$TRACE" = "1" ]; then
    set -o xtrace;
    if [ "$VERBOSE" = "1" ]; then
        set -o verbose
    fi
fi

# low_network_load(): outputs True if network activity low for given period.
# This checks whether difference from last call is below a given threshold.
# Sample /sys/class/net/ens5/statistics/rx_bytes 
#   280518007
max_network_load=10     # 10% difference
low_network_load () {
    local type="${1:-tx}"
    local current_output_file="/sys/class/net/ens5/statistics/${type}_bytes"
    local last_output_file="$TMP/${type}_bytes"
    local result=False
    ## DEBUG: echo in "low_network_load($*)" 1>&2
    
    # Determine status
    if [ -e "$last_output_file" ]; then
        local current last difference
        current=$(cat "$current_output_file")
        last=$(cat "$last_output_file")
        difference=$(echo "(($current - $last) * 100 / $last)" | bc)
        if [ "$VERBOSE" = "1" ]; then echo "$type: current=$current last=$last diff=$difference" 1>&2; fi
        echo "[$TIME] $type: current=$current last=$last diff=$difference" >> "$LOG"
        if [[ difference -le max_network_load ]]; then
            echo "Low network $type: ($difference < $max_network_load)" 1>&2
            result="True"
        fi
    fi

    # Update last output
    cat "$current_output_file" > "$last_output_file"

    # Output status
    echo "$result"
}

# low_cpu_load(): outputs True if CPU activity low for given period.
# This checks whether load average scaled by processors scale is below a threahold.
# See: https://www.brendangregg.com/blog/2017-08-08/linux-load-averages.html
# and https://stackoverflow.com/questions/11987495/what-do-the-numbers-in-proc-loadavg-mean-on-linux
# Sample /proc/loadavg
#    0.00 0.00 0.00 1/224 24347
max_cpu_load=25              # CPU load percentage
low_cpu_load () {
    local result="False"
    local avg_cpu cpu_cores actual_cpu_load
    ## DEBUG: echo in "low_cpu_load($*)" 1>&2

    # Get 15 minute average load (3rd field) and scale by number of cores
    avg_cpu=$(cut -d' ' -f3 /proc/loadavg)
    cpu_cores=$(grep -c ^processor /proc/cpuinfo)
    # This takes the actual real % load
    actual_cpu_load=$(echo "($avg_cpu * 100 / $cpu_cores)" | bc)
    if [ "$VERBOSE" = "1" ]; then echo "load: avg=$avg_cpu cores=$cpu_cores scaled=$actual_cpu_load" 1>&2; fi
    echo "[$TIME] load: avg=$avg_cpu cores=$cpu_cores scaled=$actual_cpu_load" >> "$LOG"

    # Determine status
    if [[ actual_cpu_load -le max_cpu_load ]]; then
        echo "Low cpu usage: ($actual_cpu_load < $max_cpu_load)" 1>&2
        result="True"
    fi
    echo "$result"
}

# Shutdown the server if low CPU and network usage (sending and receiving)
# Note: if DRY_RUN env. is 1, then just echo's shutdown commmand (for testing purposes)
## DEBUG: echo "checking load averages" 1>&2
cpu=$(low_cpu_load)
net_tx=$(low_network_load tx)
net_rx=$(low_network_load rx)
if [ "$cpu" = "True" ] && [ "$net_tx" = "True" ] && [ "$net_rx" = "True" ]; then
    shutdown_command="shutdown"
    if [ "${DRY_RUN:-0}" = "1" ]; then
        shutdown_command="echo $shutdown_command"
    fi
    echo "issuing: $shutdown_command"
    ## TODO???: shellcheck disable=SC2086
    $shutdown_command
fi
