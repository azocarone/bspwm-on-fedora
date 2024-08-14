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
    local pkgs_github="$1"

    local absolute_path

    echo -e "${bullets[info]} Installing packages from Repositories:"
    
    while IFS=',' read -r url target command binary cleanup; do
        if [[ ${url} == *.git ]]; then
            if [[ -n ${command} ]]; then
                absolute_path=$(clone_repo "${url}" "${target}")
                build_package "${absolute_path}" "${command}"
                [[ -n ${binary} ]] && copy_bin_folder "$absolute_path" "$binary"
                [[ ${cleanup} -eq 1 ]] && delete_work_folder "$absolute_path"
            else
                clone_repo "${url}" "${target}"
            fi
        else
            download_file "${url}" "${target}"
        fi
    done <<< "$pkgs_github"
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
    local assets=("$@")
    
    local color_scripts="${paths[home]}scripts/shell-color-scripts"

    echo -e "${bullets[info]} Processes Zsh resources"

    copy_assets "${assets[@]}" "${paths[home]}"

    rm -rf "${color_scripts}/colorscripts" "${color_scripts}/colorscript.sh"
    mv "${paths[home]}scripts/colorscripts" "$color_scripts"
    mv "${paths[home]}scripts/colorscript.sh" "$color_scripts"
    chmod +x "${color_scripts}/colorscript.sh" "${color_scripts}/colorscripts/"*
}
