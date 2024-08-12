clone_repo() {
    local git_url="$1"
    local base_path="$2"
    
    local absolute_path=$(build_absolute_path "$git_url" "$base_path")

    if ! git clone --depth=1 "$git_url" "$absolute_path"; then
        echo -e "${bullets[error]} Error: cloning the ${colors[red]}${git_url}${colors[white]} repository."
        return 1
    fi

    echo "${absolute_path}"
}

build_absolute_path() {
    local git_url="$1"
    local base_path="${2:-${paths[current]}}"
    
    local repo_name=$(basename "${git_url}" .git)
    local absolute_path="${base_path}${repo_name}"

    echo "${absolute_path}"
}

build_package() {
    local absolute_path="$1"
    local build_command="$2"
    
    local script_temp=$(mktemp)

    trap 'delete_work_folder $script_temp' EXIT

    (
        cd "$absolute_path" || {
            echo -e "${bullets[error]} Error: when changing to ${colors[red]}${absolute_path}${colors[white]} directory."
            return 1
        }

        echo "#!/bin/bash" > "$script_temp"
        echo "$build_command" >> "$script_temp"
        chmod +x "$script_temp"

        if ! ( "$script_temp" ); then
            echo -e "${bullets[error]} Error: when building the ${colors[red]}${absolute_path}${colors[white]} package."
            return 1
        fi
    )
}

copy_bin_folder(){
    local absolute_path="$1"
    local path_bin="$2"
    
    local repo_name=$(basename "${absolute_path}")
    local install_script=$(locate_install_script "${absolute_path}")
    local bin_file="$absolute_path/$repo_name"
    local function_definition=$(declare -f copy_assets)
    local command_to_run="$function_definition; copy_assets '$bin_file' '$path_bin'"
  
    [[ $install_script ]] && return
    
    [[ -f "$bin_file" ]] && sudo bash -c "$command_to_run"
}

locate_install_script(){
    local absolute_path="$1"
    local pattern="install*"
    
    if find "$absolute_path" -type f -name "$pattern" -print -quit; then
        return 0
    else
        return 1
    fi
}

delete_work_folder(){
    local cleanup="$1"

    rm -rf "$cleanup"
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

download_file(){
    local url="$1"
    local target="$2"

    local file=$(basename "$url")

    if [[ -f "$target/$file" ]]; then
        echo -e "${bullets[success]} The file ${colors[yellow]}${file}${colors[white]} already exists."
        return 1
    fi
        
    sudo mkdir -p "$target" && sudo curl -L "$url" -o "$target/$file"
    
    echo -e "${bullets[check]} The file ${colors[green]}${file}${colors[white]} downloaded successfully."
} 
