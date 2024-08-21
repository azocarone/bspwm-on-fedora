determine_clone_path() {
    local url="$1"
    local base_path="${2:-${paths[current]}}"
    
    local absolute_path
    local repo_name=$(basename "${url}" .git)
    
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
    local absolute_path="$1"
    local pattern="install*"

    if find "$absolute_path" -maxdepth 1 -name "$pattern" -type f | grep -q .; then
        return 0
    else
        return 1
    fi
}

copy_files_to_destination() {
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    local copy="cp"

    echo -e "${bullets[info]} Copy assets from directories or files:"

    # Determine if sudo is required
    [[ -e "$target" ]] && [[ ! -w "$target" ]] && copy="sudo cp"

    for asset in "${assets[@]}"; do
        if ! file_or_directory_exists "$asset"; then
            return 1
        fi

        if [[ -d "$asset" ]]; then
            $copy -rv "$asset" "$target"
        else
            $copy -v "$asset" "$target"
        fi
    done
}

make_executable() {
    local assets=("$@")

    echo -e "${bullets[info]} Sets execution permission:"

    for asset in "${assets[@]}"; do
        if ! file_or_directory_exists "$asset"; then
            return 1
        fi

        if [[ -d "$asset" ]]; then
            find "$asset" -type f -exec grep -Il '^#!' {} \; -exec chmod +x {} \;
        else
            grep -Il '^#!' "$asset" && chmod +x "$asset"
        fi
    done
}

remove_directory() {
    local cleanup="$1"

    if [[ -z "$cleanup" ]]; then
        echo -e "${bullets[error]} Error: no folder was provided for deletion."
        return 1
    fi

    if [[ ! -d "$cleanup" ]]; then
        echo -e "${bullets[error]} Error: the folder '${colors[red]}$cleanup${colors[white]}' does not exist or is not a directory."
        return 1
    fi

    rm -rf "$cleanup"
    
    if [[ $? -eq 0 ]]; then
        echo -e "${bullets[check]} The '${colors[green]}$cleanup${colors[white]}' folder has been successfully deleted."
    else
        echo -e "${bullets[error]} Error: the '${colors[red]}$cleanup${colors[white]}' folder could not be deleted."
        return 1
    fi
}

file_or_directory_exists() {
    local asset="$1"

    if [[ ! -e "$asset" ]]; then
        echo -e "${bullets[error]} Error: ${colors[red]}${asset}${colors[white]} is not a file or a directory."
        return 1
    fi

    return 0
}
