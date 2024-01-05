#! /bin/bash
# copy-readonly.sh: copies file and ensures read-only afterward
#
# TODO:
# - Warn if target exists and is not read-only.
# = Generalize to allow copying more than one file to a directory.
#
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## set -o xtrace
## set -o verbose

# Show usage statement if insufficient arguments
# TODO: allow options in any order
copy_args="-p"
force=0
if [ "$1" == "--force" ]; then
    copy_args="${copy_args}f"
    force=1
    shift
fi
if [ "$1" == "--verbose" ]; then
    copy_args="${copy_args}v"
    shift
fi
if [ "$2" == "" ]; then 
   echo ""
   echo "Usage: $0 source-file [--force] [--verbose] [file | directory]"
   echo ""
   echo "Examples (under Bash):"
   echo ""
   echo "  $0 ~/.bashrc ~/dot-file-archive"
   echo ""
   echo "  for f in copyright.py search_page.mako index.mako visual_diff_server.py; do copy-readonly \$f ~/visual-diff; done"
   echo ""
   exit
fi
source="$1"
target="$2"

# Arguments for copying: preserve timestamps, force copy, and verbose mode
# TODO: make ready by others an option
## OLD: copy_args="-pfv"
## OLD: copy_args="-pf"
new_mode="ugo+r,ugo-w"

# Do the copy, and restore read-only attribute
#
# Case 1: Copy over existing file
target_file="$target"
if [ -f "$target" ]; then  
    chmod ugo+w "$target"; 
    /bin/cp $copy_args "$source" "$target"; 
    chmod $new_mode "$target";
#
# Case 2: Copy into directory
elif [ -d "$target" ]; then
    target_file="$target/"`basename "$source"`; 
    if [ -r "$target_file" ]; then
	if [[ ($force == 0) && (-w "$target_file") ]]; then
	    echo "Error: writable target exists ($target_file)"
	    exit;
	fi
	#
	chmod ugo+w "$target_file";
    fi;
    /bin/cp $copy_args "$source" "$target"; 
    chmod $new_mode "$target_file"
#
# Case 3: Create new file
else
    /bin/cp $copy_args "$source" "$target"; 
    chmod $new_mode "$target";
fi; 

# Display file info (e.g., as a sanity check for user)
ls -alt "$target_file"
