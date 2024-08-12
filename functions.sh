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

process_zsh_assets() {
    local files=(".zshrc" ".p10k.zsh")

    # Definición de URLs y destinos
    local urls=(
        "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh"
        "https://github.com/romkatv/powerlevel10k.git"
        "https://github.com/charitarthchugh/shell-color-scripts.git"
        "https://github.com/junegunn/fzf.git"
        "https://github.com/pipeseroni/pipes.sh.git"
    )

    local targets=(
        "/usr/share/zsh-sudo"
        "${paths[home]}"
        "${paths[home]}scripts/"
        "${paths[home]}."
        "${paths[home]}scripts/"
    )

    local build_commands=(
        ""  # No command for sudo plugin
        ""  # No command for powerlevel10k
        ""  # No command for shell-color-scripts
        "${paths[home]}.fzf/install"
        ""  # No command for pipes.sh
    )

    echo -e "${bullets[info]} Deploying Zsh, installing powerlevel10k, fzf, sudo-plugin and other"
    echo -e "     packages for the ${colors[purple]}$(whoami)${colors[white]} user."

    # Copiar archivos de configuración
    copy_assets "${files[@]}" "${paths[home]}"

    # Procesar cada asset
    for i in "${!urls[@]}"; do
        if [[ ${urls[i]} == *.git ]]; then
            if [[ -n ${build_commands[i]} ]]; then
                local absolute_path=$(clone_repo "${urls[i]}" "${targets[i]}") 
                build_package "${absolute_path}" "${build_commands[i]}"
            else
                clone_repo "${urls[i]}" "${targets[i]}"
            fi
        else
            download_file "${urls[i]}" "${targets[i]}"
        fi
    done

    # Operaciones específicas para shell-color-scripts
    local color_scripts="${paths[home]}scripts/shell-color-scripts"
    rm -rf "${color_scripts}/colorscripts" "${color_scripts}/colorscript.sh"
    mv "${paths[home]}scripts/colorscripts" "$color_scripts"
    mv "${paths[home]}scripts/colorscript.sh" "$color_scripts"
    chmod +x "${color_scripts}/colorscript.sh" "${color_scripts}/colorscripts/"*
}
