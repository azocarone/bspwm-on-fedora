echo_check() {
    local temp_file="${2:-}"
    echo_message "check" "green" "$1" "$temp_file"
}

echo_error() {
    local temp_file="${2:-}"
    echo_message "error" "red" "Error: $1" "$temp_file"
}

echo_info() {
    local temp_file="${2:-}"
    echo_message "info" "blue" "$1" "$temp_file"
}

echo_success() {
    local temp_file="${2:-}"
    echo_message "success" "yellow" "$1" "$temp_file"
}

echo_message() {
    local type="$1"
    local color="$2"
    local message="$3"
    local temp_file="${4:-}"

    if [[ -z "$temp_file" ]]; then
        temp_file=$(mktemp)
        trap 'rm -f "$temp_file"' EXIT
    fi

    echo -e "${bullets[$type]} ${colors[$color]}$message${colors[white]}" 2>&1 | tee -a "$temp_file" >&2
}
