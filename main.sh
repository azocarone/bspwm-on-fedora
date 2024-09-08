#!/bin/bash
# =============================================================================
#  Project Name: bspwm-on-fedora
#  Description : Main script for installing and configuring BSPWM on Fedora
# -----------------------------------------------------------------------------
#  Author      : José AZOCAR (azocarone)
#  Created on  : 2024-09-06
# -----------------------------------------------------------------------------
#  Version     : RC4
# =============================================================================

source helpers/echo_functions.sh
source settings/config_global.sh
source helpers/verification.sh
source helpers/installation_flow.sh
source helpers/steps.sh

main() {
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
