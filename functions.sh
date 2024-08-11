source helpers.sh

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

# vvvvvvvvvvvvvvvvvvvvvvvv

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
