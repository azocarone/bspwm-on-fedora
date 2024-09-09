#!/bin/bash
# =============================================================================
#  Helper functions for displaying messages.
# -----------------------------------------------------------------------------
#  Note:
#  
#  2>&1 flow (stderr) redirected to the same place as (stdout).
#  Combined outputs 2>&1 are passed through pipe | tee -a “$temp_log” >&2
# =============================================================================

echo_bullet() {
    local color_symbol=$1
    local symbol=$2
    
    echo -e "\n${colors[white]} [${colors[$color_symbol]}$symbol${colors[white]}]"
}

echo_check() {
    echo_message "check" "green" "$1"
}

echo_error() {
    echo_message "error" "red" "Error: $1"
}

echo_info() {
    echo_message "info" "blue" "$1"
}

echo_success() {
    echo_message "success" "yellow" "$1"
}

echo_message() {
    local type="$1"
    local color="$2"
    local message="$3"

    temp_log=$(mktemp)
    trap 'rm -f "$temp_log"' EXIT

    echo -e "${bullets[$type]} ${colors[$color]}$message${colors[white]}" 2>&1 | tee -a "$temp_log" >&2
}

