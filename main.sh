#!/bin/bash

source ./deploy.sh

main() {
    source ./config.sh
    
    if confirm_installation; then
        echo -e "${bullets[info]} Starting the installation process."

        install_rpm_package "${packages[rpm]}"
        install_github_package "${packages[github]}"
        configure_rpm_packages perms_pkgs
        deploy_fonts font_paths
        setup_bspwm_assets "${bspwm_assets[@]}" "${paths[home]}"
        setup_zsh_assets "${zsh_assets[@]}"
        
        echo -e "${bullets[check]} Installation completed, please reboot to apply the configuration."
    else
        echo -e "${bullets[success]} Installation aborted."
    fi
}
 
main
