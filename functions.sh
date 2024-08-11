show_banner() {
    local banner="$1"

    clear

    if [[ ! -f "$banner" ]]; then
        echo -e "${bullets[error]} Error: ${colors[red]}${banner}${colors[white]} file not found."
        return 1
    fi

    echo -e "${colors[cyan]}" && cat "$1"
    echo -e "${bullets[info]} Scripts to install and configure a professional,"
    echo -e "     BSPWM environment on Fedora Workstation."
    echo -e "${bullets[info]} Hello, ${colors[purple]}$(whoami)${colors[white]}: deploy will begin soon."
}

prompt_continue() {
    local reply

    read -p "${bullets[question]} Do you want to continue with the installation [y/N]?: " reply

    [[ "$reply" == "y" ]]
}

install_pkgs_rpm(){
    local pkgs_rpm="$1"

    echo -e "${bullets[info]} Fedora update system:"
    sudo dnf upgrade -y --refresh

    echo -e "${bullets[info]} Install packages from RPM:"
    sudo dnf install -y ${pkgs_rpm}
}

deploy_clone(){
    local pkgs_git="$1"
    local path_bin="$2"

    local absolute_path

    echo -e "${bullets[info]} Installing packages from GitHub:"
    
    while read -r git_url build_command; do
        absolute_path=$(clone_repo "$git_url")

        if [[ ! -d "$absolute_path" ]]; then
            echo -e "${bullets[error]} Error: ${colors[red]}${absolute_path}${colors[white]} working directory does not exist." 
            return 1
        fi

        build_package "$absolute_path" "$build_command"
        copy_bin_folder "$absolute_path" "$path_bin"
        delete_work_folder "$absolute_path"
    done <<< "$pkgs_git"
}

configure_packages() {
    local -n packages=$1
    
    echo -e "${bullets[info]} Configures packages installed from RPM:"
    
    for package in "${!packages[@]}"; do
        apply_configs "${package}" "${packages[$package]}"
    done
}

copy_new_fonts() {
    local -n folders=$1
    local source="${folders[source]}"

    local order_keys=("user" "system")
    local cmd_prefix=""

    echo -e "${bullets[info]} Copying new fonts:"

    if [[ ! -d "$source" ]]; then
        echo -e "${bullets[error]} The source directory ${source} does not exist."
        return 1
    fi

    for key in "${order_keys[@]}"; do
        local target="${folders[$key]}"

        [[ $key == "system" ]] && cmd_prefix="sudo "
          
        ${cmd_prefix}mkdir -p "${target}"
        ${cmd_prefix}cp -rv "${source}"/* "${target}"
        
        source="${target}"

        echo -e "${bullets[success]} Typefaces copied to ${target}"
    done
}

process_bspwm_assets(){
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    if [ ${#assets[@]} -eq 0 ]; then
        echo -e "${bullets[error]} Error: no assets specified."
        return 1
    fi
    
    echo -e "${bullets[info]} Processes bspwm resources:"

    for asset in "${assets[@]}"; do
        copy_assets "$asset" "$target"
        add_exec_flag "$target$asset"
    done
}














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


























deploy_zsh_assets() {
    local files=(".zshrc" ".p10k.zsh")
    
    local url_one="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh"
    local target_one="/usr/share/zsh-sudo"
    
    local url_two="https://github.com/romkatv/powerlevel10k.git"
    local target_two="${paths[home]}/$(basename "$url_two" .git)"
    
    local url_four="https://github.com/junegunn/fzf.git"
    local target_four="${paths[home]}/.$(basename "$url_four" .git)"
    local command_four="${target_four}/install"
    
    local url_last="https://github.com/pipeseroni/pipes.sh.git"
    local target_last="${paths[home]}/scripts/$(basename "$url_last" .git)"
    
    echo -e "${bullets[info]} Deploying Zsh, installing powerlevel10k, fzf, sudo-plugin and other"
    echo -e "${bullets[info]} packages for the ${colors[purple]}$(whoami)${colors[white]} user.\n"

    #copy_assets "${files[@]} "${paths[home]}""
    #download_file "${url_one}" "${target_one}"
    #clone_repo "${url_two}" "${target_two}"
    #clone_and_build "${url_four}" "${target_four}" "${command_four}"
    #clone_repo "${url_last}" "${target_last}"
}

download_file(){
    local url="$1"
    local file=$(basename "$url")
    local target="$2"
    
    sudo mkdir -p "$target"

    if [[ ! -f "$target/$file" ]]; then
        sudo curl -L "$url" -o "$target/$file"
        echo -e "${bullets[check]} File downloaded successfully.\n"
    else
        echo -e "${bullets[success]} The file already exists.\n"
    fi
} 

sin_nombre(){
    cd "${paths[home]}"/scripts
    git clone https://github.com/charitarthchugh/shell-color-scripts.git
    sudo rm -rf "${paths[home]}"/scripts/shell-color-scripts/colorscripts
    sudo rm -rf "${paths[home]}"/scripts/shell-color-scripts/colorscript.sh
    cd "${paths[home]}"/scripts
    mv colorscripts colorscript.sh "${paths[home]}"/scripts/shell-color-scripts
    chmod +x "${paths[home]}"/scripts/shell-color-scripts/colorscript.sh
    cd "${paths[home]}"/scripts/shell-color-scripts/colorscripts
    chmod +x *
}
