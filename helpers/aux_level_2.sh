source ./helpers/aux_level_3.sh

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
