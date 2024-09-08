#!/bin/bash
# =============================================================================
#  Helper functions for manage installation steps.
# =============================================================================

source helpers/github_install.sh
source helpers/rpm_config.sh
source helpers/font_deploy.sh
source helpers/bspwm_setup.sh
source helpers/zsh_setup.sh

step_rpm_package_installation(){
    local pkgs_rpm="$1"

    echo_info "Fedora update system:"
    if ! sudo dnf upgrade -y --refresh; then
        echo_error "Upgrading system."
        return 1
    fi

    echo_info "RPM package installation:"
    if ! sudo dnf install -y ${pkgs_rpm}; then
        echo_error "Installing packages."
        return 1
    fi
}

step_github_package_installation() {
    local packages_list="$1"

    local repo_url target_dir build_command target_bin remove_repo repo_path
    
    echo_info "GitHub package installation:"

    while IFS=',' read -r repo_url target_dir build_command target_bin remove_repo; do
        if [[ ${repo_url} == *.git ]]; then
            repo_path=$(handle_git_repository "${repo_url}" "${target_dir}" "${build_command}" "${target_bin}")
        else
            handle_download_artifact "${repo_url}" "${target_dir}"
        fi
        handle_remove "$remove_repo" "$repo_path"
    done <<< "$packages_list"
}

step_rpm_package_configuration() {
    local -n permissions=$1

    local package
    
    echo_info "RPM package configuration:"
    
    for package in "${!permissions[@]}"; do
        install_package_configuration "${package}" "${permissions[$package]}"
    done
}

step_font_deployment() {
    local -n paths=$1

    local source="${paths[source]}"
    local order_keys=("user" "system")
    local key target cmd_prefix

    echo_info "Font deployment of user and system fonts:"

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

step_bspwm_assets_setup(){
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    local copied_assets=()

    if [ ${#assets[@]} -eq 0 ]; then
        echo_error "No assets specified."
        return 1
    fi
    
    echo_info "BSPWM assets setup:"

    comm_copy_files_to_destination "${assets[@]}" "$target"

    copied_assets=($(generate_copied_assets "${assets[@]}" "$target"))

    comm_make_executable "${copied_assets[@]}"
}

step_zsh_assets_setup() {
    local assets=("$@")

    echo_info "Zsh assets setup :"

    copy_files_to_destination "${assets[@]}" "${paths[home]}"

    handle_color_scripts "${paths[home]}/scripts"
    
    comm_make_executable "${copied_assets[@]}"
}
