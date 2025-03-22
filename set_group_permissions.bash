#! /usr/bin/env bash
#
# Makes sure directory group permissions are maintained by setting "sticky bit"
# permissions.
#
# note:
# - Based on Grok3 revision to old bash snippet.
#

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Show usage
if [ "$1" = "" ]; then
    script=$(basename "$0")
    ## TODO: base=$(basename "$0" .bash)
    echo ""
    ## TODO: add option or remove TODO placeholder
    echo "Usage: $0 [--trace] [--help] [--] dir [group=operator]"
    echo ""
    echo "Examples:"
    echo ""
    echo "CHOWN=1 sudo $0 /usr/local/misc/programs/"
    echo ""
    echo "$script ~/programs/bash/shell-scripts-devel"
    echo ""
    echo "Notes:"
    echo "- The -- option is to use default options and to avoid usage statement."
    echo "- Use CHOWN=1 to change ownership (e.g., sudo user)."
    echo "- Use FORCE=1 to bypass restrictions (e.g., chown of /home/... dir)."
    ## TODO: add more notes
    ## echo ""
    echo ""
    exit
fi
dir="$1"
group="${2:-operator}"

#...............................................................................

function todays-date { 
    date '+%d%b%y'
}

#...............................................................................

# Create a safe directory label by replacing all slashes with underscores
dir_label="${dir//\//_}"

# Use TEMP env var or default to /tmp, include timestamp in log name
log="${TMP:-/tmp}/_add-sticky-${dir_label}-$(todays-date).log"

# Clear log file
echo "" > "$log"

# Ensure SUDO_USER is set, fallback to current user if not
effective_user="${SUDO_USER:-$USER}"

# Set ownership and group with verbose output
if [ "${CHOWN:-1}" == "1" ]; then
    if [[ ("$dir" =~ /home) && ("${FORCE:-0}" == "0")  ]]; then
        echo "Error: use FORCE to change ownership of dir under /home"
        exit
    else
        chown -R --changes "$effective_user" "$dir" >> "$log" 2>&1
    fi
fi
chgrp -R --changes "$group" "$dir" >> "$log" 2>&1

# Set base permissions (read/write for group)
chmod -R --changes g+rwx "$dir" >> "$log" 2>&1

# Set execute/search for directories and apply sticky bit
find "$dir" -type d -exec chmod --changes g+s,g+x {} \; >> "$log" 2>&1

# Set default permissions for new files (using setfacl)
setfacl -R -m g::rwX "$dir" >> "$log" 2>&1
setfacl -R -m d:g::rwX "$dir" >> "$log" 2>&1

# Show results
echo "Permission changes log: $log"
wc "$log"
tail "$log"
