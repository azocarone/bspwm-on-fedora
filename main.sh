#!/bin/bash

source configs/formatting.sh
source configs/messages.sh
source configs/packages.sh
source configs/variables.sh

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
    if ! confirm_installation; then
        return 1
    fi

    source  helpers/level_1.sh
    source  helpers/level_2.sh
    source  helpers/level_3.sh
    source  helpers/level_4.sh

    echo_info "Starting the installation process."

    #if ! install_rpm_package "${packages[rpm]}"; then
    #    return 1
    #fi

    #if ! install_packages_from_github "${packages[github]}"; then
    #    return 1
    #fi

    if ! configure_rpm_packages perms_pkgs; then
        return 1
    fi

    # if ! deploy_fonts font_paths; then
    #     return 1
    # fi

    # if ! setup_bspwm_assets "${bspwm_assets[@]}" "${paths[home]}"; then
    #     return 1
    # fi

    # if ! setup_zsh_assets "${zsh_assets[@]}"; then
    #     return 1
    # fi
        
    echo_check "Installation completed, please reboot to apply the configuration."
}
 
if ! main; then
    echo_error "Installation failed."
    exit $?
fi
