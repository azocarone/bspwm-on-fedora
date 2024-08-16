#!/bin/bash

source functions.sh

main() {
    source config.sh
    
    if prompt_continue; then
        echo -e "${bullets[info]} Starting the installation process."

        #install_pkgs_rpm "${packages[rpm]}"
        deploy_clone "${packages[github]}"
        #configure_packages privileges
        #copy_new_fonts directories
        #process_bspwm_assets "${bspwm_assets[@]}" "${paths[home]}"
        #process_zsh_assets "${zsh_assets[@]}"
        
        echo -e "${bullets[check]} Installation completed, please reboot to apply the configuration."
    else
        echo -e "${bullets[success]} Installation aborted."
    fi
}

main
