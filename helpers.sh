show_banner() {
    local banner="$1"

    clear

    if [[ ! -f "$banner" ]]; then
        echo -e "${bullets[error]} Error: ${colors[red]}${banner}${colors[white]} file not found."
        return 1
    fi

    echo -e "${colors[cyan]}"
    cat "$banner"
    
    echo -e "${bullets[info]} Scripts to install and configure a professional,"
    echo -e "     BSPWM environment on Fedora Workstation."
    echo -e "${bullets[info]} Hello, ${colors[purple]}${USERNAME}${colors[white]}: deploy will begin soon."
}

clone_repo() {
    local url="$1"
    local target="$2"
    
    local absolute_path=$(build_absolute_path "$url" "$target")

    if git clone --depth=1 "$url" "$absolute_path"; then
        echo "${absolute_path}"
    else
        echo -e "${bullets[error]} Error: cloning the ${colors[red]}${url}${colors[white]} repository."
        return 1
    fi
}

build_absolute_path() {
    local url="$1"
    local base_path="${2:-${paths[current]}}"
    
    local repo_name=$(basename "${url}" .git)
    #local repo_name="${url##*/}"
    #repo_name="${repo_name%.git}"
    
    local absolute_path="${base_path}/${repo_name}"

    echo "${absolute_path}"
}

build_package() {
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

copy_bin_folder() {
    local absolute_path="$1"
    local target="$2"
    
    local repo_name=$(basename "$absolute_path")
    local bin_file="$absolute_path/$repo_name"

    if locate_install_script "$absolute_path"; then
        return
    fi

    if [[ -f "$bin_file" ]]; then
        copy_assets "$bin_file" "$target"
    fi
}

locate_install_script() {
    local absolute_path="$1"
    local pattern="install*"

    if find "$absolute_path" -maxdepth 1 -name "$pattern" -type f | grep -q .; then
        return 0
    else
        return 1
    fi
}

download_file(){
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

delete_work_folder() {
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
        echo -e "${bullets[check]} The '${colors[red]}$cleanup${colors[white]}' folder has been successfully deleted."
    else
        echo -e "${bullets[error]} Error: the '${colors[red]}$cleanup${colors[white]}' folder could not be deleted."
        return 1
    fi
}

apply_configs() {
    local package="$1"
    local execute="$2"

    local source="${paths[current]}.config/${package}"
    local target="${paths[home]}.config/${package}" 

    [[ -d "${target}" ]] && delete_work_folder "${target}"
    
    copy_assets "${source}" "${target}"
    
    [[ "${execute}" -eq 1 ]] && add_exec_flag "${target}"
}

copy_assets() {
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    echo -e "${bullets[info]} Copy assets from directories or files:"
       
    for asset in "${assets[@]}"; do
        if ! is_valid_asset "$asset"; then
            return 1
        fi

        if [[ -d "$asset" ]]; then
            cp -rv "$asset" "$target"
        else
            cp -v "$asset" "$target"
        fi
    done
}

add_exec_flag() {
    local assets=("$@")

    echo -e "${bullets[info]} Sets execution permission:"

    for asset in "${assets[@]}"; do
        if ! is_valid_asset "$asset"; then
            return 1
        fi

        if [[ -d "$asset" ]]; then
            find "$asset" -type f -exec grep -Il '^#!' {} \; -exec chmod +x {} \;
        else
            grep -Il '^#!' "$asset" && chmod +x "$asset"
        fi
    done
}

is_valid_asset() {
    local asset="$1"

    if [[ ! -e "$asset" ]]; then
        echo -e "${bullets[error]} Error: ${colors[red]}${asset}${colors[white]} is not a file or a directory."
        return 1
    fi

    return 0
}
