source ./helpers/lvl_3.sh

expand_path() {
    local target_dir="$1"
    
    local resolved_path

    case "$target_dir" in
        ".") resolved_path="${paths[current]}" ;;
        "~") resolved_path="${paths[home]}" ;;
        "~/"*)
            # Remove the “~/” and add the path to home
            resolved_path="${paths[home]}/${target_dir:2}" ;;
        /*)
            # Any absolute path is returned as is
            resolved_path="$target_dir" ;;
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

    if git clone --depth=1 "$url" "$repo_path"; then
        echo "${repo_path}"
    else
        echo_error "Cloning the ${repo_url} repository failed."
        return 1
    fi
}

build_from_source() {
    local repo_path="$1"
    local build_command="$2"

    [[ -z ${build_command} ]] && {
        echo_success "No building is required."
        return 0
    }

    local script_temp=$(mktemp)

    # Trap with anonymous function.
    trap 'rm -f "$script_temp"' EXIT 
    
    # Sub-shell so as not to alter or change the current working directory.
    ( 
        cd "$repo_path" || {
            echo_error "Changing to ${repo_path} directory failed."
            return 1
        }

        # Implement a Heredocs
        cat > "$script_temp" <<EOF
#!/bin/bash
$build_command
EOF
        chmod +x "$script_temp"

        if ! ( "$script_temp" ); then
            echo_error "Building the package in ${repo_path} failed."
            return 1
        fi
     )
}

deploy_executable() {
    local repo_path="$1"
    local target_bin="$2"
    
    [[ -z ${target_bin} ]] && {
        echo_success "No executable deployment needed."
        return 0
    }

    local repo_name=$(basename "$repo_path")
    local bin_file="$repo_path/$repo_name"

    if has_install_script "$repo_path"; then
        echo_success "Installation script found; skipping executable deployment."
        return 0
    fi

    if [[ -f $bin_file ]]; then
        copy_files_to_destination "$bin_file" "$target_bin"
    else
        echo_error "Binary file ${bin_file} does not exist."
        return 1
    fi
}

download_artifact(){
    local repo_url="$1"
    local base_path="$2"

    local file=$(basename "$url")

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

    if [[ "$success" = true ]]; then
        return 0
    else
        return 1
    fi
}

determine_copy_command() {
    local target="$1"
    
    [[ -e "$target" && ! -w "$target" ]] && echo "sudo cp" || echo "cp"
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

file_or_directory_exists() {
    local asset="$1"

    if [[ ! -e "$asset" ]]; then
        echo_error "${asset} is not a file or a directory."
        return 1
    fi

    return 0
}
