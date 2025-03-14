#!/bin/bash
# Determine the script's directory
# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
## NOTE: the test scripts should reside in ./tests (as with run_tests.bash, etc.).
## OLD: SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
 
# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")/.."

# Use TMPDIR if TMP is not set
TMP="${TMP:-${TMPDIR:-/tmp}}"

# Initialize RL to 0 if not set
RL="${RL:-0}"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
case $1 in
--source) SOURCE_SCRIPT="$2"; shift ;;
*) OTHER_ARGS+=("$1") ;;
esac
shift
done

# Source the external script if provided
if [[ -n "$SOURCE_SCRIPT" ]]; then
    # Ensure the source script exists and is readable
    if [[ ! -f "$SOURCE_SCRIPT" ]]; then
        echo "Error: Source script '$SOURCE_SCRIPT' not found."
        exit 1
    fi
    # Source the script
    source "$SOURCE_SCRIPT"
fi

# Ensure PYTHONPATH includes the parent directory of tests
export PYTHONPATH="${SCRIPT_DIR}:${PYTHONPATH}"

# Debug: Print full paths for verification
echo "Script Directory: $SCRIPT_DIR"
echo "Run Tests Script: $SCRIPT_DIR/tests/run_tests.bash"
echo "PYTHONPATH: $PYTHONPATH"
echo "Temporary Directory: $TMP"

# Default configuration and safety checks
test_regex="${TEST_REGEX:-(README|coverage_test)}"
debug_level="${BATSPP_DEBUG_LEVEL:-4}"

# Main infrastructure testing function
main() {
    # Check if running under the correct user (optional, can be modified)
    if [ "$USER" != "testuser" ]; then
        echo "Warning: tests should ideally be run under user testuser"
        read -p "Press Enter to continue or Ctrl+C to abort..." 
    fi

    # Additional debugging: Check if run_tests.bash exists and is executable
    if [[ ! -f "$SCRIPT_DIR/tests/run_tests.bash" ]]; then
        echo "Error: run_tests.bash not found in $SCRIPT_DIR/tests/"
        exit 1
    fi

    if [[ ! -x "$SCRIPT_DIR/tests/run_tests.bash" ]]; then
        echo "Error: run_tests.bash is not executable"
        exit 1
    fi

    # Set up BatsPP specific directories
    export BATSPP_BASE="$TMP/batspp"

    # Increment run log counter
    ((RL++))

    # Create log filename with error checking
    log="${TMP}/_run_tests-$(date +%Y%m%d-%H%M%S).$RL.log"
    echo "Log file will be: $log"

    # Ensure log directory exists
    mkdir -p "$(dirname "$log")"

    # Set up directories
    mkdir -p "$BATSPP_BASE"
    export SINGLE_STORE=1
    export BATSPP_OUTPUT="$BATSPP_BASE/out"
    export BATSPP_TEMP="$BATSPP_BASE/tmp"

    # Sanity check on number of test files
    num_test_files=$(ls tests/*.ipynb tests/test_*.py 2>/dev/null | grep -E "$test_regex" | wc -l)
    echo "Number of test files found: $num_test_files"

    if [[ ($num_test_files -eq 0) || ($num_test_files -ge 10) ]]; then
        echo "Warning: unusual number of tests to be run ($num_test_files)"
        read -p "Press Enter to continue or Ctrl+C to abort..." 
    fi

    # Comprehensive test run configuration
    OUTPUT_DIR="$TMP" \
    DEBUG_LEVEL="$debug_level" \
    SUB_DEBUG_LEVEL="$debug_level" \
    TEST_REGEX="$test_regex" \
    FORCE_RUN=1 \
    REMAP_TMP=1 \
    USE_SSH_AUTH=0 \
    PRESERVE_GIT_STASH=0 \
    "$SCRIPT_DIR/tests/run_tests.bash" -o > "$log" 2>&1

    # Capture and report test status
    status="$?"
    echo "Test run status: $status"
    return "$status"
}

# Run the main testing function
main "${OTHER_ARGS[@]}"
exit $?