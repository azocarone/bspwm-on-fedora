source ./helpers/auxiliary.sh

confirm_installation() {
    local reply

    display_installation_banner "${files[banner]}"
    
    while true; do
        read -rp "${bullets[question]} Do you want to continue with the installation [y/n]?: " reply

        case "${reply,,}" in # Convert to lowercase
            y)
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
    local target cmd_prefix

    echo -e "${bullets[info]} Deploying fonts:"

    if [[ ! -d "$source" ]]; then
        echo -e "${bullets[error]} Error: the source directory ${colors[red]}${source}${colors[white]} does not exist."
        return 1
    fi

    for key in "${order_keys[@]}"; do
        target="${paths[$key]}"

        cmd_prefix=$(determine_sudo_command "$key")
       
        deploy_fonts_to_target "$source" "$target" "$cmd_prefix"

        source="${target}"
    done
}

setup_bspwm_assets(){
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    local copied_assets=()

    if [ ${#assets[@]} -eq 0 ]; then
        echo -e "${bullets[error]} Error: no assets specified."
        return 1
    fi
    
    echo -e "${bullets[info]} Processes bspwm resources:"

    copy_files_to_destination "${assets[@]}" "$target"

    copied_assets=($(generate_copied_assets "${assets[@]}" "$target"))

    make_executable "${copied_assets[@]}"
}

setup_zsh_assets() {
    local assets=("$@")
    
    echo -e "${bullets[info]} Processes Zsh resources"

    copy_files_to_destination "${assets[@]}" "${paths[home]}"
    handle_color_scripts
}
