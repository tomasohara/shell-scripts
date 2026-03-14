#!/usr/bin/env bash
#
# Purpose:
#   Connect to an Android device over USB tether using classic
#   ADB TCP mode (port 5555).
#
# Requirements:
#   - USB debugging enabled
#   - USB tethering enabled
#   - Device connected via USB
#
# What this script does:
#   1. Verifies a USB ADB device is available
#   2. Switches adbd to TCP mode on port 5555
#   3. Detects the phone's USB tether (rndis0) IP address
#   4. Connects to that IP over TCP
#   5. Verifies the connection
#
# Note:
# - Developed with POE Assistant and Gemini.
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

#...............................................................................

# Enable strict execution
# See https://foreops.com/blog/enhancing-bash-script-reliability-with-set-xeuo-pipefail
if [ "${STRICT:-0}" = "1" ]; then
    set -euo pipefail
fi

# Initialize
PORT=5555
PRETTY=0
CONFIRMED=0
DELAY=3

#...............................................................................

# sleep-for(seconds, [task]): sleep for SECONDS for TASK (e.g., "connection")
# TODO2: simplying invocation
function sleep-for {
    local sec="${1:-$DELAY}"
    local task="${2:-"for effect"}"
    local msg="pausing ${sec} sec for $task"
    echo "$msg"
    sleep "$sec"
}

# Parse arguments
#
usage() {
    cat <<EOF
Usage: $0 [--pretty] [--delay N] [--help | -h] [-]

Example: $(basename "$0") -

Options:
  --delay S   Number of seconds to wait after adb changes
  --pretty    Enable emoji/status decorations in output
  -h, --help  Show this help message
  -           Confirm execution (required)

Notes:
  Environment options: DEBUG_LEVEL, STRICT, TRACE, and VERBOSE.
EOF
    exit 0
}
#
if [[ $# -eq 0 ]]; then
    usage
fi
#
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pretty) PRETTY=1; shift ;;
        --delay)
            if [[ -n "${2:-}" ]]; then
                DELAY="$2"
                shift 2
            else
                echo "Error: --delay requires an argument."
                usage
            fi
            ;;
        -h|--help) usage ;;
        -) CONFIRMED=1; shift ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done
#
if [[ $CONFIRMED -ne 1 ]]; then
    usage
fi

# msg(emoji, text): Outputs TEXT with optional EMOJI (if PRETTY enabled)
#
msg() {
    local emoji="$1"
    local text="$2"

    # Sanity check: ensure text is printable ASCII only
    if LC_ALL=C grep -q '[^ -~]' <<<"$text"; then
        echo "Internal error: non-ASCII text in msg(): $text" >&2
        exit 1
    fi

    if [[ $PRETTY -eq 1 ]]; then
        echo "$emoji $text"
    else
        echo "$text"
    fi
}

#...............................................................................

# Startup
echo "== ADB USB‑Tether TCP Connector =="

# Detect existing TCP connection (idempotent behavior)
USB_PRESENT=0
USB_SERIAL=$(adb devices | awk 'NR>1 && $2=="device" && $1 !~ /:/ {print $1; exit}')
if [[ -n "$USB_SERIAL" ]]; then
    USB_PRESENT=1
    PHONE_IP=$(adb -s "$USB_SERIAL" shell ip route 2>/dev/null | awk '/rndis0/ {print $9; exit}')
else
    PHONE_IP=""
fi
#
if [[ -n "${PHONE_IP:-}" ]]; then
    TARGET="$PHONE_IP:$PORT"
    if adb devices | grep -E -q "^$TARGET\s+device"; then
        msg "✅" "Already connected to $TARGET"
        echo
        echo "== Active ADB Devices =="
        adb devices
        exit 0
    fi
fi

# Step 1: Ensure a USB device is connected and authorized
if [[ $USB_PRESENT -ne 1 ]]; then
    msg "❌" "No USB device detected. Connect device and enable USB debugging."
    exit 1
fi
#
msg "✅" "USB device detected."

# Step 2: Restart adbd in TCP mode on port 5555
# (Safe to run repeatedly; adbd may briefly restart.)
msg "🔁" "Ensuring TCP mode on port $PORT..."
adb -s "$USB_SERIAL" tcpip "$PORT" 1>/dev/null 2>&1 || true
sleep-for "$DELAY" "tcp mode"

# Step 3: Extract phone IP for USB tether interface (rndis0)
PHONE_IP=$(adb -s "$USB_SERIAL" shell ip route 2>/dev/null | awk '/rndis0/ {print $9; exit}')
#
if [[ -z "${PHONE_IP:-}" ]]; then
    msg "❌" "Could not detect rndis0 IP. Is USB tethering enabled?"
    exit 1
fi
#
TARGET="$PHONE_IP:$PORT"
msg "🔎" "Detected phone USB IP: $PHONE_IP"

# Step 4: Attempt TCP connection
# Retry briefly to handle adbd restart timing after 'adb tcpip'
msg "⏳" "Connecting to $TARGET..."
for attempt in {1..10}; do
    CONNECT_OUTPUT=$(adb connect "$TARGET" 2>&1 || true)
    if echo "$CONNECT_OUTPUT" | grep -E -q "connected|already connected"; then
        msg "✅" "Successfully connected to $TARGET [attempt $attempt]"
        echo
        echo "== Active ADB Devices =="
        adb devices
        exit 0
    fi
    sleep-for 0.5 "tcpip connection"
done

# Wrapup
msg "❌" "TCP connection failed after multiple attempts."
echo "$CONNECT_OUTPUT"
exit 1
