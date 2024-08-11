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

process_zsh_assets() {
    local files=(".zshrc" ".p10k.zsh")
    
    local url_2="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh"
    local target_2="/usr/share/zsh-sudo"
    
    local url_3="https://github.com/romkatv/powerlevel10k.git"
    local target_3="${paths[home]}$(basename "$url_3" .git)"
        
    local url_4="https://github.com/charitarthchugh/shell-color-scripts.git"
    local target_4="${paths[home]}scripts/$(basename "$url_4" .git)"

    local url_5="https://github.com/junegunn/fzf.git"
    local target_5="${paths[home]}/.$(basename "$url_5" .git)"
    local command_5="${target_5}/install"
    
    local url_6="https://github.com/pipeseroni/pipes.sh.git"
    local target_6="${paths[home]}/scripts/$(basename "$url_6" .git)"
    
    echo -e "${bullets[info]} Deploying Zsh, installing powerlevel10k, fzf, sudo-plugin and other"
    echo -e "${bullets[info]} packages for the ${colors[purple]}$(whoami)${colors[white]} user."

    copy_assets "${files[@]}" "${paths[home]}"
    download_file "${url_2}" "${target_2}"
    clone_repo "${url_3}" "${target_3}"
    clone_repo "${url_4}" "${target_4}"
    rm -rf "${target_4}/colorscripts"
    rm -rf "${target_4}/colorscript.sh"
    mv "${paths[home]}scripts/colorscripts" "${target_4}"
    mv "${paths[home]}scripts/colorscript.sh" "${target_4}"
    chmod +x "${target_4}/colorscript.sh"
    chmod +x "${target_4}/colorscripts/*"
    clone_and_build "${url_5}" "${target_5}" "${command_5}"
    clone_repo "${url_6}" "${target_6}"
}

download_file(){
    local url="$1"
    local file=$(basename "$url")
    local target="$2"
    
    sudo mkdir -p "$target"

    if [[ ! -f "$target/$file" ]]; then
        sudo curl -L "$url" -o "$target/$file"
        echo -e "${bullets[check]} File downloaded successfully."
    else
        echo -e "${bullets[success]} The file already exists."
    fi
} 
