#!/bin/bash
# =============================================================================
#  Project Name: bspwm-on-fedora
#  Description : Main script for installing and configuring BSPWM on Fedora
# -----------------------------------------------------------------------------
#  Author      : José AZOCAR (azocarone)
#  Created on  : 2024-09-09
# -----------------------------------------------------------------------------
#  Version     : RC5
# =============================================================================

source helpers/echo_func.sh
source settings/global.sh
source helpers/main_utils.sh
source helpers/step.sh

main() {
    main_check_exists "${files[banner]}" || return 1
    main_display_banner "${files[banner]}"
    main_confirm_installation || {
        echo_error "Installation aborted."
        return 1
    }

    local -A steps=(
        #[rpm_installation]=${packages[rpm]}
        #[github_installation]="${packages[github]}"
        #[rpm_configuration]="rpm_pkgs_permissions"
        #[font_deployment]="font_paths"
        #[bspwm_setup]="${bspwm_assets[@]} ${paths[home]}"
        [zsh_setup]="${zsh_assets[@]}"
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
