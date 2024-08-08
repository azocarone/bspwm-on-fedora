#!/bin/bash

source functions.sh

main() {
    source config.sh

    show_banner "${files[banner]}"
  
    if ! prompt_continue; then
        echo -e "${bullets[success]} Installation aborted."
        return 1
    fi

    echo -e "${bullets[info]} Starting the installation process." 

    ##install_pkgs_rpm "${packages[rpm]}"
    ##deploy_clone "${packages[github]}" "${paths[bin]}"
    ##configure_packages privileges
    ##copy_new_fonts directories
    #deploy_bspwm_assets "${assets[@]}" "${paths[home]}"
    #deploy_zsh_assets

    echo -e "${bullets[check]} Installation completed, please reboot to apply the configuration."
}

main
