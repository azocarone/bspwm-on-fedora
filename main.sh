#!/bin/bash

source functions.sh

main() {
    source config.sh
    
    if confirm_installation; then
        echo -e "${bullets[info]} Starting the installation process."

        #install_rpm_package "${packages[rpm]}"
        #install_github_package "${packages[github]}"
        configure_rpm_packages privileges
        #copy_new_fonts directories
        #process_bspwm_assets "${bspwm_assets[@]}" "${paths[home]}"
        #process_zsh_assets "${zsh_assets[@]}"
        
        echo -e "${bullets[check]} Installation completed, please reboot to apply the configuration."
    else
        echo -e "${bullets[success]} Installation aborted."
    fi
}

main
