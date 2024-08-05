#!/bin/bash

source functions.sh

main() {
    source config.sh

    show_banner "${files[banner]}"
    
    if ! prompt_continue; then
        echo -e "${bullets[success]} Installation aborted."
        return 1
    fi

    echo -e "${bullets[info]} Starting the installation process.\n" 

    # install_pkgs_rpm "${packages[rpm]}"
    deploy_clone "${packages[github]}" "${paths[bin]}"
    #configure_packages packages_permission
    #copy_font_folders paths_fonts
    #deploy_bspwm_assets "${paths[home]}" "${assets[@]}"
    #deploy_zsh_assets

    echo -e "${bullets[check]} Installation completed, please reboot to apply the configuration."
}

main
