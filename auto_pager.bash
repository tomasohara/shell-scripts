#! /usr/bin/env bash
#
# Script to scroll through file automatically.
#
# via Claude-AI (Dec 2024):
#
# Original Prompt:
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
#

# Get CLI args
file="$1"
delay="${DELAY:-5}"
TMP="${TMP:-/tmp}"
USER="${USER:-user}"
DEBUG="${DEBUG:-0}"
MARGIN="${MARGIN:-2}"                   # Margin lines for readability
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
MAX_LINES=$((LINES - 2 * MARGIN))       # Max lines to show
COLUMNS=$(tput cols)                    # Likewise for width
if [ "$DEBUG" == "1" ]; then
    let MAX_LINES-=2
fi
page=0
total_lines=$(wc -l < "$file")
num_pages=$((((total_lines + MAX_LINES - 1) / MAX_LINES) + 1))
loop_count=0

# Do the scrolling
while [ "$start" -lt "$total_lines" ]; do
    let page+=1
    last_start="$start"

    # Sanity check
    let loop_count+=1
    if [ "$loop_count" -gt "$total_lines" ]; then
        echo "# Unexpected termination check"
        break
    fi
    
    # Clear screen preserving scrollback
    clear -x
    for (( i=0; i < $MARGIN; i++)); do
         echo ""
    done
    
    # Display current page
    if [ "$DEBUG" == "1" ]; then
        echo "# Page $page/$num_pages of $file"
    fi
    
    # Get current page content with original line numbers
    page_text=$(nl -ba -w4 -s' ' "$file" | tail --lines=+"$start" | head --lines="$MAX_LINES")
    
    # Calculate actual display lines needed including word wrap
    display_lines=0
    while IFS= read -r line; do
        let display_lines+=1
        line_length=${#line}
        if [ "$line_length" -gt "$COLUMNS" ]; then
            let display_lines+=$((line_length / COLUMNS))
        fi
    done <<< "$page_text"
    
    # Calculate how many source lines we can show
    effective_lines=$display_lines
    if [ "$effective_lines" -gt "$MAX_LINES" ]; then
        # If wrapped content exceeds page, reduce lines shown
        let effective_lines=$MAX_LINES
    fi
    let effective_lines-=$MARGIN
    if [ "$effective_lines" -lt 0 ]; then
        effective_lines=1
    fi
    
    # Display the content
    echo "$page_text" | head -n "$effective_lines"
    
    # Advance to next section
    start=$((start + effective_lines))
    
    # Debug output
    if [ "$DEBUG" == "1" ]; then
        echo "# s=$last_start t=$total_lines rows=$MAX_LINES max_rows=$MAX_LINES cols=$COLUMNS display=$display_lines effective=$effective_lines margin=$MARGIN"
    fi
    
    sleep "$delay"
done
