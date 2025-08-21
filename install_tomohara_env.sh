#!/bin/bash

# =====================================================================
# Script: install-tomohara-env.sh
# Purpose: Appends the Tomohara dynamic environment setup to ~/.bashrc.
# This script is idempotent. It will not add the configuration
# block if it already exists, preventing configuration duplication.
# =====================================================================

# Define the target file and a unique identifier for our configuration block.
BASHRC_FILE="$HOME/.bashrc"
BLOCK_IDENTIFIER="TOMOHARA DYNAMIC PROJECT ENVIRONMENT SETUP"

# --- Verification Step ---
# Check if the configuration block has already been installed.
# This is the correct way to prevent duplicate entries.
if grep -q "$BLOCK_IDENTIFIER" "$BASHRC_FILE"; then
    echo "[INFO] Tomohara environment block already detected in $BASHRC_FILE."
    echo "[INFO] No changes are necessary. Exiting."
    exit 0
fi

# --- Installation Step ---
# The configuration block does not exist. We will now append it.
# A 'here document' with a quoted delimiter ('EOF') is used to ensure
# that variables like $HOME are written literally to the file, not
# expanded by the shell running this script.

echo "[ACTION] Appending Tomohara v2 environment to $BASHRC_FILE..."

# Add a newline for clean separation before our block.
echo "" >> "$BASHRC_FILE"

cat << 'EOF' >> "$BASHRC_FILE"
# =====================================================================
# === TOMOHARA DYNAMIC PROJECT ENVIRONMENT SETUP (v2) ===
# =====================================================================
# This block dynamically locates the project directory to support forks
# and ensures all paths are portable.

# --- Part 1: Auto-detect the Project Directory ---
# It will prefer your fork ('shell-scripts-aveey') if it exists.
if [ -d "$HOME/shell-scripts-aveey" ]; then
    export TOMOHARA_PROJECT_DIR="$HOME/shell-scripts-aveey"
elif [ -d "$HOME/shell-scripts" ]; then
    export TOMOHARA_PROJECT_DIR="$HOME/shell-scripts"
else
    # If neither is found, set the variable to empty.
    export TOMOHARA_PROJECT_DIR=""
fi

# --- Part 2: Configure Environment if Project was Found ---
if [ -n "$TOMOHARA_PROJECT_DIR" ]; then
    # Set batspp temporary data paths
    export BATSPP_BASE="/tmp/batspp"
    mkdir -p "$BATSPP_BASE/out" "$BATSPP_BASE/tmp"
    export SINGLE_STORE=1
    export BATSPP_OUTPUT="$BATSPP_BASE/out"
    export BATSPP_TEMP="$BATSPP_BASE/tmp"

    # Add the project directory to PATH (for scripts like perlgrep.perl)
    export PATH="$TOMOHARA_PROJECT_DIR:$PATH"

    # Add the project directory to PYTHONPATH (for python modules)
    # NOTE: We use $TOMOHARA_PROJECT_DIR, NOT a hardcoded path.
    export PYTHONPATH="$TOMOHARA_PROJECT_DIR:$PYTHONPATH"

    # Source the tomohara-aliases if the file exists
    if [ -f "$TOMOHARA_PROJECT_DIR/tomohara-aliases.bash" ]; then
        source "$TOMOHARA_PROJECT_DIR/tomohara-aliases.bash"
    fi

    # Print confirmation with the detected path
    echo "[tomohara-env] Initialized using project dir: $TOMOHARA_PROJECT_DIR"
else
    echo "[tomohara-env] WARNING: No project directory found (shell-scripts or shell-scripts-aveey)."
fi

# --- Part 3: Standard User Bin Directory ---
# This is kept separate as it's a general user setting, not project-specific.
export PATH="$HOME/bin:$PATH"

# === END TOMOHARA DYNAMIC PROJECT ENVIRONMENT SETUP ===
EOF

# --- Finalization ---
echo "[SUCCESS] The Tomohara environment block has been installed."
echo "To activate the new environment, you must reload your shell configuration."
echo "Run the following command:"
echo "    source ~/.bashrc"

exit 0
