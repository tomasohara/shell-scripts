#! /usr/bin/env bash
#
# Script to scroll through file automatically.
#
# via Claude-AI (Dec 2024):
#
# Prompt:
# Is there a way to scroll through a file under Bash or Linux/Ubuntu one page at a time with pages advanced every 5 seconds or so? This is to support hands-free review so to speak.
# Response:
# Yes, you can use the less command combined with a simple bash script to achieve this. Let me create a script that will help you do this automatically.
# Auto-scrolling script for file reviewClick to open code
# To use this script:
# 
# Save it to a file (e.g., autoscroll.sh)
# Make it executable: chmod +x autoscroll.sh
# Run it with your file: ./autoscroll.sh yourfile.txt
# 
# The script will:
# 
# Open your file in less
# Automatically advance one page every 5 seconds
# Stop at the end of the file
# Exit automatically when finished
# 
# You can modify the sleep duration (currently 5 seconds) by changing the number in the sleep 5 command if you want it faster or slower.
# Would you like me to explain how it works or modify any part of it?
#
# TODO:
# - start=0; watch -n 1 "clear -x; tail --lines=+$((start)) debug.py | tail -n $LINES; start += $LINES"
#

# Get CLI args
file="$1"
delay="${DELAY:-5}"
TMP="${TMP:-/tmp}"
USER="${USER:-user}"
DEBUG="${DEBUG:-0}"
if [ "$file" == "" ]; then
    script=$(basename "$0")
    echo "Usage: '$script' file [delay=5]"
    echo ""
    echo "Examples:"
    echo "$0 machine_translation.py"
    echo ""
    echo "DELAY=1 find . -iname '*notes*.txt > \$TMP/all-notes"
    echo "$0 \$TMP/all-notes 1"
    echo ""
    echo "Note:"
    echo "- Uses DELAY to override pause seconds"
    exit
fi

# Initialize
# note: Lines per pages includes header and line at bottom (for prompt)
start=1                                 # Start from first line
LINES=$(tput lines)                     # Get terminal height
COLUMNS=$(tput columns)                 # Likewise width
## TODO: let lines-=1
let LINES-=2
if [ "$DEBUG" == "1" ]; then
    let LINES-=1
fi

page=0
total_lines=$(wc -l < "$file")
num_pages=$((((total_lines + lines - 1) / lines) + 1))

# Do the scrolling
extra=0
while [ "$start" -lt "$total_lines" ]; do
    let page+=1
    # Clear screen preserving scrollback
    clear -x
    if [ "$DEBUG" == "1" ]; then
        echo "start=$start total_lines=$total_lines lines=$line columns=$COLUMNS extra=$extra"
    fi
    # Display current page
    page_file="$TMP/$USER-page-$$.list"
    echo "Page $page/$num_pages of $file"
    cat --number "$file" | tail --lines=+"$start" |  head --lines="$LINES" >| "$page_file"
    cat "$page_file"

    # Check for word wrap
    num_chars=$(wc -c < "$page_file")
    extra_lines=$(((num_chars + 1) / columns))

    # Update start and pause
    start=$((start + LINES - extra_lines))
    sleep "$delay"
done
