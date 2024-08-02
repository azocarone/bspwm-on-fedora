#!/bin/bash

source functions.sh

main() {
    source config.sh

    show_banner "${files[banner]}"
    
    if ! ask_installation_confirmation; then
        echo -e "${bullets[success]} Installation aborted."
        return 1
    fi

    echo -e "${bullets[info]} Starting the installation process.\n" 

    #update_and_install_rpm_packages "${packages[rpm]}"
    #install_git_packages "${packages[git]}" "${paths[install]}"
    #copy_and_configure_packages packages_permission
    #copy_assets_and_set_permissions "${paths[home]}" "${assets[@]}"
    #copy_fonts_to_directories paths_fonts
    
    #sin_nombre

    echo -e "${bullets[check]} Installation completed, please reboot to apply the configuration."
}

main
