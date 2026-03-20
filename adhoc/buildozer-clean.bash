#!/bin/bash
#
# buildozer-clean.bash: Wrapper for 'buildozer -v android clean' that works
# even when p4a hasn't been cloned yet (works around upstream bug where
# cmd_clean doesn't guard against a missing python-for-android directory).
#
# note: via Copilot/Claude
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

# Enable strict execution
# See https://foreops.com/blog/enhancing-bash-script-reliability-with-set-xeuo-pipefail
if [ "${STRICT:-0}" = "1" ]; then
    set -euo pipefail
fi

# Globals
BUILDOZER_DIR=".buildozer"
P4A_DIR="$BUILDOZER_DIR/android/platform/python-for-android"

function usage {
    echo "Usage: $0 [--quiet|-q] [--full|-f]" >&2
    echo ""
    echo "Example: $(basename "$0") -"
    echo ""
    echo "Notes:"
    echo "- Normally just cleans '$P4A_DIR'."
    echo "- With --full, '$BUILDOZER_DIR' removed."
    echo "- Environment options: DEBUG_LEVEL, STRICT, TRACE, and VERBOSE."
    exit 1
}

function log {
    if [ "$quiet" = false ]; then
        echo "$*"
    fi
}

#...............................................................................

# Parse arguments
#
quiet=false
full=false
#
if [[ $# -eq 0 ]]; then
    usage
fi
#
for arg in "$@"; do
    case "$arg" in
        --quiet|-q) quiet=true ;;
        --full|-f) full=true ;;
        -) true ;;
        *) usage ;;
    esac
done

# Create skeleton to avoid buildozer error
created_skeleton=false
if [ ! -d "$P4A_DIR" ]; then
    log "Workaround: $P4A_DIR not found (p4a not yet cloned)."
    log "Workaround: Creating skeleton directory so 'buildozer android clean' can proceed."
    mkdir -p "$P4A_DIR"
    created_skeleton=true
else
    log "Status: $P4A_DIR exists; proceeding with clean."
fi

# Do the cleanup
log "Status: Running 'buildozer -v android clean'..."
buildozer -v android clean
log "Status: Clean completed successfully."

# Optionally, remove entire build directory if
if $full; then
    ## TODO3: use 'buildozer appclean' instead?
    log "Removing $BUILDOZER_DIR"
    rm -rf "$BUILDOZER_DIR"
fi

# Remove the skeleton if we created it and it's still empty
if [ "$created_skeleton" = true ] && [ -z "$(ls -A "$P4A_DIR" 2>/dev/null)" ]; then
    log "Workaround: Removing skeleton directory (nothing was created by clean)."
    rmdir "$P4A_DIR"
fi
