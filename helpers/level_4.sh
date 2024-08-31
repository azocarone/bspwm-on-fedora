determine_clone_path() {
    local repo_url="$1"
    local base_path="${2:-${paths[current]}}"
    
    local repo_name=$(basename "${repo_url}" .git)
    local repo_path # Type absolute path
    
    if [[ "${base_path}" == *"/." ]]; then
        # Case 1: if base_path ends in “/.”, do not add “/”.
        repo_path="${base_path}${repo_name}"
    else
        # Case 2: in any other case, add “/”.
        repo_path="${base_path}/${repo_name}"
    fi

    echo "${repo_path}"
}

directory_or_file_exists() {
    local path="$1"

    if [[ -e "$path" ]]; then
        return 0
    else
        echo_error "The specified path ${path} does not exist."
        return 1
    fi
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
