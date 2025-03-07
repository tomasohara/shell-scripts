#! /usr/bin/env bash
#
# Makes sure directory group permissions are maintained by setting "sticky bit"
# permissions.
#
# note:
# - Based on Grok3 revision to old bash snippet.
#

# Show usage
if [ "$1" = "" ]; then
    script=$(basename "$0")
    ## TODO: base=$(basename "$0" .bash)
    echo ""
    ## TODO: add option or remove TODO placeholder
    echo "Usage: $0 [--TODO] [--trace] [--help] [--] dir [group=operator]"
    echo ""
    echo "Examples:"
    echo ""
    ## TODO: example 1
    echo "sudo $0 /usr/local/misc/programs/"
    echo ""
    ## TODO: example 2
    echo "$script ~/programs/bash/shell-scripts-devel"
    echo ""
    echo "Notes:"
    echo "- The -- option is to use default options and to avoid usage statement."
    ## TODO: add more notes
    ## echo ""
    echo ""
    exit
fi
dir="$1"
group="${2:-operator}"

# Set directory to provided DIR or current working directory if not specified
dir="${DIR:-$PWD}"

# Create a safe directory label by replacing all slashes with underscores
dir_label="${dir//\//_}"

# Use TEMP env var or default to /tmp, include timestamp in log name
log="${TMP:-/tmp}/_add-sticky-${dir_label}-$(T).log"

# Clear log file
echo "" > "$log"

# Ensure SUDO_USER is set, fallback to current user if not
effective_user="${SUDO_USER:-$USER}"

# Set ownership and group with verbose output
chown -R --changes "$effective_user" "$dir" >> "$log" 2>&1
chgrp -R --changes "$group" "$dir" >> "$log" 2>&1

# Set base permissions (read/write for group)
chmod -R --changes g+rw "$dir" >> "$log" 2>&1

# Set execute/search for directories and apply sticky bit
find "$dir" -type d -exec chmod --changes g+s,g+x {} \; >> "$log" 2>&1

# Set default permissions for new files (using setfacl)
setfacl -R -m g::rwX "$dir" >> "$log" 2>&1
setfacl -R -m d:g::rwX "$dir" >> "$log" 2>&1

# Show results
echo "Permission changes log: $log"
wc "$log"
tail "$log"
