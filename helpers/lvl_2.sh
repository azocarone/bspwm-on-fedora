source ./helpers/lvl_3.sh

expand_path() {
    local target="$1"
    
    local resolved_path

    case "$target" in
        ".")
            resolved_path="${paths[current]}"
            ;;
        "~")
            resolved_path="${paths[home]}"
            ;;
        "~/"*)
            # Remove the “~/” and add the path to home
            resolved_path="${paths[home]}/${target:2}"
            ;;
        /*)
            # Any absolute path is returned as is
            resolved_path="$target"
            ;;
        *)
            echo "Target not recognized: $target"
            return 1
            ;;
    esac

    echo "$resolved_path"
}

clone_repository() {
    local url="$1"
    local base_path="$2"
    
    local absolute_path=$(determine_clone_path "$url" "$base_path")

    if git clone --depth=1 "$url" "$absolute_path"; then
        echo "${absolute_path}"
    else
        echo -e "${bullets[error]} Error: cloning the ${colors[red]}${url}${colors[white]} repository."
        return 1
    fi
}

build_from_source() {
    local absolute_path="$1"
    local command="$2"
    
    local script_temp=$(mktemp)

    # Trap with anonymous function.
    trap 'rm -f "$script_temp"' EXIT 
    
    # Sub-shell so as not to alter or change the current working directory.
    ( 
    
        cd "$absolute_path" || {
            echo -e "${bullets[error]} Error: when changing to ${colors[red]}${absolute_path}${colors[white]} directory."
            return 1
        }

        # Implement a Heredocs
        cat > "$script_temp" <<EOF
#!/bin/bash
$command
EOF

        chmod +x "$script_temp"

        if ! ( "$script_temp" ); then
            echo -e "${bullets[error]} Error: when building the ${colors[red]}${absolute_path}${colors[white]} package."
            return 1
        fi
    )
}

deploy_executable() {
    local absolute_path="$1"
    local target="$2"
    
    local repo_name=$(basename "$absolute_path")
    local bin_file="$absolute_path/$repo_name"

    if has_install_script "$absolute_path"; then
        return
    fi

    if [[ -f "$bin_file" ]]; then
        copy_files_to_destination "$bin_file" "$target"
    fi
}

download_artifact(){
    local url="$1"
    local target="$2"

    local file=$(basename "$url")

    if [[ -f "$target/$file" ]]; then
        echo -e "${bullets[success]} The file ${colors[yellow]}${file}${colors[white]} already exists."
        return 1
    fi
        
    if sudo mkdir -p "$target" && sudo curl -L "$url" -o "$target/$file"; then
        echo -e "${bullets[check]} The file ${colors[green]}${file}${colors[white]} downloaded successfully."
    else
        echo -e "${bullets[error]} Error: failed to download the file ${colors[red]}${file}${colors[white]}."
        return 1
    fi
} 

remove_items() {
    local items=("$@")

    local item
    local success=true

    if [[ ${#items[@]} -eq 0 ]]; then
        echo -e "${bullets[error]} Error: no directories or files were provided for deletion."
        return 1
    fi

    for item in "${items[@]}"; do
        if [[ -d "$item" ]]; then
            delete_directory "$item" || success=false
        elif [[ -f "$item" ]]; then
            delete_file "$item" || success=false
        else
            echo -e "${bullets[error]} Error: ${colors[red]}$item${colors[white]} is not a directory or file."
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
        echo -e "${bullets[error]} Error: ${colors[red]}${asset}${colors[white]} is not a file or a directory."
        return 1
    fi

    return 0
}
