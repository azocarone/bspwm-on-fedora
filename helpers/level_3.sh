expand_path() {
    local target_dir="$1"
    
    local resolved_path

    case "$target_dir" in
        ".") 
            resolved_path="${paths[current]}"
            ;;
        "~")
            resolved_path="${paths[home]}"
            ;;
        "~/"*)
            # Remove the “~/” and add the path to home
            resolved_path="${paths[home]}/${target_dir:2}"
            ;;
        /*)
            # Any absolute path is returned as is
            resolved_path="$target_dir"
            ;;
        *)
            echo_error "The target directory ${target_dir} is not recognized."
            return 1
            ;;
    esac

    echo "$resolved_path"
}

clone_repository() {
    local repo_url="$1"
    local base_path="$2"
    
    local repo_path=$(determine_clone_path "$repo_url" "$base_path")
    
    if directory_or_file_exists "$repo_path"; then
        return 1
    fi
    
    if ! git clone --depth=1 "$repo_url" "$repo_path"; then
        echo_error "Cloning the ${repo_url} repository failed."
        return 1
    fi

    echo "${repo_path}"
}

build_from_source() {
    local repo_path="$1"
    local build_command="$2"

    if [[ -z $build_command ]]; then
        echo_success "No building is required."
        return 0
    fi

    local build_log=$(mktemp)
    trap 'rm -f "$build_log"' EXIT 

    if ! (
        cd "$repo_path" &&
        bash -c "$build_command" 2>&1 | tee -a "$build_log" >&2
    ); then
        echo_error "Building the package in ${repo_path} failed."
        return 1
    fi
}

deploy_executable() {
    local repo_path="$1"
    local target_bin="$2"

    if [[ -z ${target_bin} ]]; then
        echo_success "No executable deployment needed."
        return 0
    fi

    local deploy_log=$(mktemp)
    trap 'rm -f "$deploy_log"' EXIT 

    local repo_name=$(basename "$repo_path")
    local bin_file="$repo_path/$repo_name"

    if has_install_script "$repo_path"; then
        echo_success "Installation script found; skipping executable deployment."
        return 0
    fi

    if [[ -f $bin_file ]]; then
        copy_files_to_destination "$bin_file" "$target_bin" 2>&1 | tee -a "$deploy_log" >&2
    else
        echo_error "Binary file ${bin_file} does not exist."
        return 1
    fi
}

download_artifact(){
    local repo_url="$1"
    local base_path="$2"

    local file=$(basename "$repo_url")

    if [[ -f "$base_path/$file" ]]; then
        echo_success "The file ${file}$ already exists."
        return 1
    fi
        
    if sudo mkdir -p "$base_path" && sudo curl -L "$repo_url" -o "$base_path/$file"; then
        echo_check "The file ${file} downloaded successfully."
    else
        echo_error "Failed to download the file ${file}."
        return 1
    fi
} 

remove_items() {
    local items=("$@")

    local item
    local success=true

    if [[ ${#items[@]} -eq 0 ]]; then
        echo_error "No directories or files were provided for deletion."
        return 1
    fi

    for item in "${items[@]}"; do
        if [[ -d "$item" ]]; then
            delete_directory "$item" || success=false
        elif [[ -f "$item" ]]; then
            delete_file "$item" || success=false
        else
            echo_error "${item} is not a directory or file."
            success=false
        fi
    done

    [[ "$success" = true ]] && return 0 || return 1
}

determine_copy_command() {
    local target="$1"
    local temp_file="$2"
    
    [[ -e "$target" && ! -w "$target" ]] && echo "sudo cp" || echo "cp"
}

process_asset() {
    local asset="$1"
    local target="$2"
    local copy_cmd="$3"
    local temp_file="$4"

    if ! directory_or_file_exists "$asset"; then
        return 1
    fi

    if [[ -d "$asset" ]]; then
        $copy_cmd -rv "$asset" "$target"
    else
        $copy_cmd -v "$asset" "$target"
    fi
}
