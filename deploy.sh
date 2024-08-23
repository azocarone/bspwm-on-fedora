source ./helpers/core.sh

confirm_installation() {
    local reply

    display_installation_banner "${files[banner]}"
    
    while true; do
        read -rp "${bullets[question]} Do you want to continue with the installation [y/n]?: " reply

        case "${reply,,}" in # Convert to lowercase
            y)
                #if [[ $UID -ne 0 ]]; then
                #    echo -e "${bullets[success]} You need to run this script with Root user permissions."
                #    return 1
                #fi
                return 0
                ;;
            n)
                return 1
                ;;
            *)
                echo -e "${bullets[error]} Error: invalid answer. Please enter 'y' or 'n'."
                ;;
        esac
    done
}

install_rpm_package(){
    local pkgs_rpm="$1"

    echo -e "${bullets[info]} Fedora update system:"
    if ! sudo dnf upgrade -y --refresh; then
        echo -e "${bullets[error]} Error: upgrading system."
        return 1
    fi

    echo -e "${bullets[info]} Install packages from RPM:"
    if ! sudo dnf install -y ${pkgs_rpm}; then
        echo -e "${bullets[error]} Error: installing packages."
        return 1
    fi
}

install_packages_from_github() {
    local packages_list="$1"
    local url target command binary remove
    
    echo -e "${bullets[info]} Installing packages from Repositories:"

    while IFS=',' read -r url target command binary remove; do
        if [[ ${url} == *.git ]]; then
            repo_path=$(handle_git_repository "${url}" "${target}" "${command}" "${binary}")
        else
            handle_download_artifact "${url}" "${target}"
        fi

        [[ ${remove} -eq 1 ]] && handle_remove "$repo_path"
    done <<< "$packages_list"
}

configure_rpm_packages() {
    local -n permissions=$1
    
    echo -e "${bullets[info]} Configures packages installed from RPM:"
    
    for package in "${!permissions[@]}"; do
        install_package_configuration "${package}" "${permissions[$package]}"
    done
}

deploy_fonts() {
    local -n paths=$1
    local source="${paths[source]}"

    local order_keys=("user" "system")
    local cmd_prefix=""

    echo -e "${bullets[info]} Deploying fonts:"

    if [[ ! -d "$source" ]]; then
        echo -e "${bullets[error]} Error: the source directory ${colors[red]}${source}${colors[white]} does not exist."
        return 1
    fi

    for key in "${order_keys[@]}"; do
        local target="${folders[$key]}"

        [[ $key == "system" ]] && cmd_prefix="sudo "
          
        ${cmd_prefix}mkdir -p "$target"
        ${cmd_prefix}cp -rv "$source"/* "$target"
        
        source="${target}"

        echo -e "${bullets[check]} Fonts deployed to ${colors[green]}$target${colors[white]}"
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
