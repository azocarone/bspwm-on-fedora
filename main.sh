#!/bin/bash
# =============================================================================
#  Project Name: bspwm-on-fedora
#  Description : Scripts to install and configure a professional 
#                BSPWM environment on Fedora Linux Workstation. 
# -----------------------------------------------------------------------------
#  Author      : José AZOCAR (azocarone)
#  Created on  : 2024-09-03
#  Version     : RC1
# -----------------------------------------------------------------------------
#  Usage       : chmod +x main.sh root.sh ; ./main.sh ; sudo ./root.sh
# =============================================================================

confirm_installation() {
    local reply

    display_installation_banner "${files[banner]}"
    
    while true; do
        reply=$(read_user_confirmation)
        case "${reply}" in 
            y)
                return 0
                ;;
            n)
                return 1
                ;; 
            *)
                echo_error "Invalid answer. Please enter 'y' or 'n'."
                ;;
        esac
    done
}

display_installation_banner() {
    local banner="$1"

    clear
    
    if [[ ! -f "$banner" ]]; then
        echo_error "${banner} file not found."
        return 1
    fi

    echo -e "${colors[cyan]}" && cat "$banner"
    echo_info "Scripts to install and configure a professional,"
    echo -e "     ${colors[blue]}BSPWM environment on Fedora Workstation.${colors[white]}"
    echo_info "Hello, ${colors[purple]}${USERNAME}${colors[blue]}: deploy will begin soon."
}

read_user_confirmation() {
    local reply
    
    read -rp "${bullets[question]} Do you want to continue with the installation [y/n]?: " reply
    
    echo "${reply,,}" #  Convert to lowercase ",," and return the answer
}

main() {
    confirm_installation || return 1

    local helpers=("helpers/level_1.sh" "helpers/level_2.sh" "helpers/level_3.sh" "helpers/level_4.sh")

    for helper in "${helpers[@]}"; do
        source "$helper"
    done

    echo_info "Starting the installation process."

    install_rpm_packages "${packages[rpm]}" &&
    install_packages_from_github "${packages[github]}" &&
    configure_rpm_packages rpm_pkgs_permissions &&
    deploy_fonts font_paths &&
    setup_bspwm_assets "${bspwm_assets[@]}" "${paths[home]}" &&
    setup_zsh_assets "${zsh_assets[@]}" &&
            
    echo_check "Installation completed, please reboot to apply the configuration."
}

local configs=("configs/formatting.sh" "configs/messages.sh" "configs/packages.sh" "configs/variables.sh")

for config in "${configs[@]}"; do
    source "$config"
done

if ! main; then
    echo_error "Installation failed."
    exit $?
fi
