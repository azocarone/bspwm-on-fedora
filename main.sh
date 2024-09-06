#!/bin/bash
# =============================================================================
#  Project Name: bspwm-on-fedora
#  Description : Scripts to install and configure a professional 
#                BSPWM environment on Fedora Linux Workstation. 
# -----------------------------------------------------------------------------
#  Author      : José AZOCAR (azocarone)
#  Created on  : 2024-09-06
#  Version     : RC3
# -----------------------------------------------------------------------------
#  Usage       : Script and main execution function.
#               
#                1. > chmod +x main.sh root.sh
#                2. > ./main.sh
#                3. > sudo ./root.sh
# =============================================================================

source configs/formatting.sh
source configs/messages.sh
source configs/packages.sh
source configs/variables.sh

confirm_installation() {
    display_installation_banner "${files[banner]}"

    while true; do
        read -rp "${bullets[question]} Do you want to continue with the installation [y/n]?: " reply
        case "${reply,,}" in  # Convert input to lowercase
            y) return 0 ;; # Continue
            n) return 1 ;; # Exit
            *) echo_error "Invalid answer. Please enter 'y' or 'n'." ;;
        esac
    done
}

display_installation_banner() {
    local banner="$1"

    clear

    if [[ ! -f "$banner" ]]; then
        echo_error "Banner file ${banner} not found."
        return 1
    fi

    echo -e "${colors[cyan]}"
    cat "$banner"
    echo_info "Scripts to install and configure a professional,"
    echo -e "     ${colors[blue]}BSPWM environment on Fedora Workstation.${colors[white]}"
    echo_info "Hello, ${colors[purple]}${USERNAME}${colors[blue]}: deployment will begin soon."
}

run_or_fail() {
    local function="$1"
    local description="$2"
    shift 2  # Remove the first two arguments (function and description)
    local parameters=("$@")  # Remaining arguments are the parameters

    if ! "$function" "${parameters[@]}"; then
        echo_error "$description failed."
        exit 1
    fi
}

main() {
    confirm_installation || { echo_error "Installation aborted."; exit 1; }

    declare -A steps=(
        [rpm_package_installation]="RPM package installation,${packages[rpm]}"
        #[github_package_installation]="GitHub package installation,${packages[github]}"
        #[rpm_package_configuration]="RPM package configuration,rpm_pkgs_permissions"
        #[font_deployment]="Font deployment,font_paths"
        #[bspwm_assets_setup]="BSPWM assets setup,${bspwm_assets[@]} ${paths[home]}"
        #[zsh_assets_setup]="ZSH assets setup,${zsh_assets[@]}"
    )
    
    source helpers/steps.sh
    
    echo_info "Starting the installation process."

    for function in "${!steps[@]}"; do
        IFS="," read -r description parameters <<< "${steps[$function]}" # Split the value by the delimiter ","
        run_or_fail "$function" "$description" $parameters
    done

    echo_check "Installation completed, please reboot to apply the configuration."
}

if ! main; then
    echo_error "Installation failed."
    exit 1
fi
