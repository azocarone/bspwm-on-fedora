install_rpm_package(){
    local pkgs_rpm="$1"

    echo_info "Fedora update system:"
    if ! sudo dnf upgrade -y --refresh; then
        echo_error "Upgrading system."
        return 1
    fi

    echo_info "Install packages from RPM:"
    if ! sudo dnf install -y ${pkgs_rpm}; then
        echo_error "Installing packages."
        return 1
    fi
}

install_packages_from_github() {
    local packages_list="$1"

    local repo_url target_dir build_command target_bin remove_repo repo_path
    
    echo_info "Installing packages from Repositories:"

    while IFS=',' read -r repo_url target_dir build_command target_bin remove_repo; do
        if [[ ${repo_url} == *.git ]]; then
            repo_path=$(handle_git_repository "${repo_url}" "${target_dir}" "${build_command}" "${target_bin}")
        else
            handle_download_artifact "${repo_url}" "${target_dir}"
        fi
        handle_remove "$remove_repo" "$repo_path"
    done <<< "$packages_list"
}

configure_rpm_packages() {
    local -n permissions=$1

    local package
    
    echo_info "Configures packages installed from RPM:"
    
    for package in "${!permissions[@]}"; do
        install_package_configuration "${package}" "${permissions[$package]}"
    done
}

deploy_fonts() {
    local -n paths=$1

    local source="${paths[source]}"
    local order_keys=("user" "system")
    local key target cmd_prefix

    echo_info "Deploying fonts:"

    if [[ ! -d "$source" ]]; then
        echo_error "The source directory ${source} does not exist."
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
        echo_error "No assets specified."
        return 1
    fi
    
    echo_info "Processes bspwm resources:"

    copy_files_to_destination "${assets[@]}" "$target"

    copied_assets=($(generate_copied_assets "${assets[@]}" "$target"))

    make_executable "${copied_assets[@]}"
}

setup_zsh_assets() {
    local assets=("$@")
    
    echo_info "Processes Zsh resources"

    copy_files_to_destination "${assets[@]}" "${paths[home]}"
    handle_color_scripts "${paths[home]}/scripts"
}
