#!/bin/bash
# =============================================================================
#  Project Name: bspwm-on-fedora
#  Description : Main script for installing and configuring BSPWM on Fedora
# -----------------------------------------------------------------------------
#  Version     : RC3
# =============================================================================

source helpers/echo_functions.sh
source helpers/verification.sh
source helpers/installation_flow.sh
source helpers/steps.sh
source configs/settings.sh

main() {
    #local configs=("packages")

    #for config in "${configs[@]}"; do
    #    check_file_exists "configs/${config}.sh" || return 1
    #    source "configs/${config}.sh"
    #done

    check_file_exists "${files[banner]}" || return 1
    display_installation_banner "${files[banner]}"
    confirm_installation || {
        echo_error "Installation aborted."
        return 1
    }

    local -A steps=(
        [rpm_package_installation]=${packages[rpm]}
        #[github_package_installation]="${packages[github]}"
        #[rpm_package_configuration]="rpm_pkgs_permissions"
        #[font_deployment]="font_paths"
        #[bspwm_assets_setup]="${bspwm_assets[@]} ${paths[home]}"
        #[zsh_assets_setup]="${zsh_assets[@]}"
    )

    echo_info "Starting the installation process."
    
    for function in "${!steps[@]}"; do
        step_"$function" "${steps[$function]}" || {
            echo_error "The step $function failed."
            return 1
        }
    done

    echo_check "Installation completed, please reboot to apply the configuration."
}

main || exit 1
