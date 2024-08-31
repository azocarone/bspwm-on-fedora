echo_check() {
    echo_message "check" "green" "$1"
}

echo_error() {
    echo_message "error" "red" "Error: $1" >&2
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

    echo -e "${bullets[$type]} ${colors[$color]}$message${colors[white]}"
}
