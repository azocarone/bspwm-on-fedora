determine_copy_command() {
    local target="$1"
    [[ -e "$target" && ! -w "$target" ]] && echo "sudo cp" || echo "cp"
}

file_or_directory_exists() {
    local asset="$1"

    if [[ ! -e "$asset" ]]; then
        echo -e "${bullets[error]} Error: ${colors[red]}${asset}${colors[white]} is not a file or a directory."
        return 1
    fi

    return 0
}
