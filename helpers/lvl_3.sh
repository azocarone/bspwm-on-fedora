determine_clone_path() {
    local repo_url="$1"
    local base_path="${2:-${paths[current]}}"
    
    local repo_path # Type absolute path
    local repo_name=$(basename "${repo_url}" .git)
    
    if [[ "${base_path}" == *"/." ]]; then
        # Case 1: If base_path ends in “/.”, do not add “/”.
        repo_path="${base_path}${repo_name}"
    else
        # Case 2: In any other case, add “/”.
        repo_path="${base_path}/${repo_name}"
    fi

    echo "${repo_path}"
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
        echo_error "The directory ${dir} could not be removed."
        return 1
    else
        echo_check "The directory ${dir} has been successfully removed."
        return 0
    fi
}

delete_file() {
    local file="$1"

    rm -f "$file"
    
    if [[ $? -ne 0 ]]; then
        echo_error "The file ${file} could not be deleted."
        return 1
    else
        echo_check "The file ${file} has been successfully deleted."
        return 0
    fi
}

echo_check() {
    echo -e "${bullets[check]} ${colors[green]}$1${colors[white]}"
}

echo_error() {
    echo -e "${bullets[error]} Error: ${colors[red]}$1${colors[white]}"
}

echo_info() {
    echo -e "${bullets[info]} ${colors[blue]}$1${colors[white]}"
}

echo_success() {
    echo -e "${bullets[success]} ${colors[yellow]}$1${colors[white]}"
}
