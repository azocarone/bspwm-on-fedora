source ./helpers/aux_level_4.sh

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

    local copy_cmd

    echo -e "${bullets[info]} Copy assets from directories or files:"

    copy_cmd=$(determine_copy_command "$target")

    for asset in "${assets[@]}"; do
        process_asset "$asset" "$target" "$copy_cmd" || return 1
    done
}

process_asset() {
    local asset="$1"
    local target="$2"
    local copy_cmd="$3"

    if ! file_or_directory_exists "$asset"; then
        return 1
    fi

    if [[ -d "$asset" ]]; then
        $copy_cmd -rv "$asset" "$target"
    else
        $copy_cmd -v "$asset" "$target"
    fi
}
