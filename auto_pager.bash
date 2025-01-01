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
BOTTOM_SPACE="${BOTTOM_SPACE:-2}"                   # extra space at bottom
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
start=1                                 # Start from first line
LINES=$(tput lines)                     # Get terminal height
COLUMNS=$(tput cols)                    # Likewise for width
let LINES-=2                            # Account for header and prompt
let LINES-=$BOTTOM_SPACE
if [ "$DEBUG" == "1" ]; then
    let LINES-=1
fi
page=0
total_lines=$(wc -l < "$file")
num_pages=$((((total_lines + LINES - 1) / LINES) + 1))

# Do the scrolling
extra=0
while [ "$start" -lt "$total_lines" ]; do
    let page+=1
    last_start="$start"
    
    # Clear screen preserving scrollback
    clear -x

    # Display current page
    echo "# Page $page/$num_pages of $file"
    
    # Get current page content with original line numbers
    page_text=$(nl -ba -w4 -s' ' "$file" | tail --lines=+"$start" | head --lines="$LINES")
    
    # Calculate wrapped lines
    wrapped_lines=0
    while IFS= read -r line; do
        # Add 1 for the base line
        let wrapped_lines+=1
        # Add any additional wrapped lines (accounting for the line number prefix)
        line_length=${#line}
        if [ "$line_length" -gt "$COLUMNS" ]; then
            additional_wraps=$(((line_length + COLUMNS - 1) / COLUMNS - 1))
            let wrapped_lines+=additional_wraps
        fi
    done <<< "$page_text"
    
    # Update start position accounting for wrapped lines
    effective_lines=$((LINES - (wrapped_lines - LINES)))
    if [ "$effective_lines" -lt 1 ]; then
        effective_lines=1
    fi
    start=$((start + effective_lines))
    extra=$((LINES - effective_lines))
    
    # Display the page with original line numbers
    # skip overlap space at end
    echo "$page_text" | head -"$effective_lines"

    # Pause for effect
    if [ "$DEBUG" == "1" ]; then
        echo "# start=$last_start total_lines=$total_lines lines=$LINES columns=$COLUMNS extra=$extra effective=$effective_lines"
    fi
    sleep "$delay"
done
