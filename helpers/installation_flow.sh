#!/bin/bash
# =============================================================================
#  Helper func. for manage installation flow (display banner, user confirmation).
# =============================================================================

display_installation_banner() {
    local banner="$1"

    clear
    echo -e "${colors[cyan]}"
    cat "$banner"
    echo_info "Scripts to install and configure a professional,"
    echo -e "     ${colors[blue]}BSPWM environment on Fedora Workstation.${colors[white]}"
    echo_info "Hello, ${colors[purple]}${USERNAME}${colors[blue]}: deployment will begin soon."
}

confirm_installation() {
    local attempts=3

    while (( attempts > 0 )); do
        read -rp "${bullets[question]} Do you want to continue with the installation [y/n]?: " reply
        case "${reply,,}" in
            y) return 0 ;;
            n) return 1 ;;
            *) 
                (( attempts-- ))
                echo_error "Invalid answer. Please enter 'y' or 'n'. Remaining attempts: $attempts."
                ;;
        esac
    done
    
    echo_error "Maximum attempts reached. Exiting."
    return 1
}
