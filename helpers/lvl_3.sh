determine_clone_path() {
    local repo_url="$1"
    local base_path="${2:-${paths[current]}}"
    
    local absolute_path
    local repo_name=$(basename "${repo_url}" .git)
    
    if [[ "${base_path}" == *"/." ]]; then
        # Case 1: If base_path ends in “/.”, do not add “/”.
        absolute_path="${base_path}${repo_name}"
    else
        # Case 2: In any other case, add “/”.
        absolute_path="${base_path}/${repo_name}"
    fi

    echo "${absolute_path}"
}

has_install_script() {
    local repo_path="$1"

    local pattern="install*"

    if find "$repo_path" -maxdepth 1 -name "$pattern" -type f | grep -q .; then
        return 0
    else
        return 1
    fi
}

delete_directory() {
    local dir="$1"

    rm -rf "$dir"
    
    if [[ $? -ne 0 ]]; then
        echo -e "${bullets[error]} Error: the directory ${colors[red]}$dir${colors[white]} could not be removed."
        return 1
    else
        echo -e "${bullets[check]} The directory ${colors[green]}$dir${colors[white]} has been successfully removed."
        return 0
    fi
}

delete_file() {
    local file="$1"

    rm -f "$file"
    
    if [[ $? -ne 0 ]]; then
        echo -e "${bullets[error]} Error: the file ${colors[red]}$file${colors[white]} could not be deleted."
        return 1
    else
        echo -e "${bullets[check]} The file ${colors[green]}$file${colors[white]} has been successfully deleted."
        return 0
    fi
}
