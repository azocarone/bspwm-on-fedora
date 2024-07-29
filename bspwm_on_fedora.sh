#!/bin/bash

source functions.sh

main() {
    source config.sh

    display_banner "${files[banner]}"
    
    if ! confirm_installation; then
        echo -e "${bullets[surprise]} Installation aborted."
        return
    fi

    echo -e "${bullets[info]} Starting the installation process.\n" 

    #install_rpm_packages "${packages[rpm]}"
    #deploy_git_packages "${packages[git]}" "${paths[install]}"

    copy_all_package_configurations packages_permission
    
    #copy_bspwm_scripts
    #copy_bspwm_themes
    #copy_fonts
    #temporal

    echo -e "${bullets[check]} Installation completed, please reboot to apply the configuration."
}

main
