#! /usr/bin/env bash
#
# find-git-branch.sh: Locates active Git branches and worktrees across multiple repositories.
#
# Scans a specified base directory (defaults to /tpo) up to a set depth to find
# all Git repositories. For each repository, it inspects both the primary root
# directory and any linked Git worktrees to see if they match a targeted branch name.
#
# Note:
# - See bash-cheatsheet.md for commonly used bash snippets.
# - This was inspired by locating forgotten linked git worktrees across projects.
# - via Gemini 3.1 Pro
#
# Set bash regular and/or verbose tracing
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#
if [ "${DEBUG_LEVEL:-0}" -ge 4 ]; then
    echo "$0 $*"
fi
if [[ "${TRACE:-0}" == "1" ]]; then
    set -o xtrace
fi
if [[ "${VERBOSE:-0}" == "1" ]]; then
    set -o verbose
fi
if [[ "${STRICT:-0}" == "1" ]]; then
    set -euo pipefail
fi

# Display command-line usage
function usage() {
    local script
    script=$(basename "$0")
    echo ""
    echo "Usage: $script <branch-name> [--dir <base-dir>] [--max-depth <depth>] [--verbose] [--trace] [--help] [-- | -]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$script fix-template-table"
    echo ""
    echo "$script development --dir /home/user/projects --max-depth 4"
    echo ""
    echo "Notes:"
    echo "- The -- option uses defaults and avoids the usage statement."
    echo "- Use DEBUG_SCRIPT=1 to show getopt processing."
    echo "- Base directory defaults to /tpo if the --dir option is omitted."
    echo "- Max depth defaults to 3 levels down if the --max-depth option is omitted."
    echo ""
}

# Initialize options
show_usage=0
trace=0
verbose=0
base_dir="/tpo"
max_depth=3

DEBUG_SCRIPT=$([ "${DEBUG_SCRIPT:-0}" -eq 1 ] && echo true || echo false)

# Parse options with getopt
# Note:
# - getopt unravels combined short options (e.g., "-tv" -> "-t -v")
# - options taking a value argument have a colon appended (e.g., "dir:").
TEMP=$(getopt -o hd:m:tv --long help,dir:,max-depth:,trace,verbose -n "$0" -- "$@")
status=$?
if [ $status != 0 ]; then
    echo "Error: getopt failed (status=$status); terminating." >&2
    exit 1
fi
$DEBUG_SCRIPT && echo "TEMP=$TEMP"
# Reassign $1, $2, etc. to the normalized getopt output.
# Note: quotes around "$TEMP" are essential.
eval set -- "$TEMP"

# Process each option
while true; do
    $DEBUG_SCRIPT && echo "\$1=$1"
    case "$1" in
        -h|--help)
            show_usage=1
            shift
            ;;
        -d|--dir)
            base_dir="$2"
            shift 2
            ;;
        -m|--max-depth)
            max_depth="$2"
            shift 2
            ;;
        -t|--trace)
            trace=1
            shift
            ;;
        -v|--verbose)
            verbose=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error: unexpected option: $1" >&2
            exit 1
            ;;
    esac
done

# Apply trace and verbose now that they've been parsed
# note: This is the preferred way to trace the script proper
if [ "$trace" == "1" ]; then
    set -o xtrace
fi
if [ "$verbose" == "1" ]; then
    set -o verbose
fi

# Show usage if --help or if no positional arguments remain (target branch is required)
if [ "$show_usage" == "1" ] || [ "$#" -eq 0 ]; then
    usage
    exit
fi

# Assign positional arguments
target_branch="$1"

# Validate base directory
if [ ! -d "$base_dir" ]; then
    echo "Error: Base directory '$base_dir' does not exist." >&2
    exit 1
fi

if [ "$verbose" == "1" ]; then
    echo "Scanning '$base_dir' (max-depth: $max_depth) for branch: '$target_branch'..."
    echo "----------------------------------------------------------------------"
fi

# Find all Git roots (directories or file pointers for submodules/worktrees)
find "$base_dir" -maxdepth "$max_depth" -name ".git" \( -type d -o -type f \) | while read -r gitdir; do
    repo_root=$(dirname "$gitdir")
    
    # Run git worktree list inside the context of the discovered repo
    git -C "$repo_root" worktree list 2>/dev/null | while read -r wt_line; do
        if echo "$wt_line" | grep -q "\[$target_branch\]"; then
            # Safely strip everything from the first space followed by a hex commit hash to isolate the path
            wt_path=$(echo "$wt_line" | sed -E 's/ +[0-9a-fA-F]{7,40} +\[.*\]//')
            printf "Found Branch [%s] checked out at: %s\n" "$target_branch" "$wt_path"
        fi
    done
done
