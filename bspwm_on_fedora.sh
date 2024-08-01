#!/bin/bash

source functions.sh

main() {
    source config.sh

    display_banner "${files[banner]}"
    
    if ! confirm_installation; then
        echo -e "${bullets[success]} Installation aborted."
        return
    fi

    echo -e "${bullets[info]} Starting the installation process.\n" 

    #install_rpm_packages "${packages[rpm]}"
    #deploy_git_packages "${packages[git]}" "${paths[install]}"
    #copy_and_configure_all_packages packages_permission
    #copy_bspwm_assets "scripts" ".themes"
    #copy_fonts paths_fonts
    
    #sin_nombre

    echo -e "${bullets[check]} Installation completed, please reboot to apply the configuration."
}

main
