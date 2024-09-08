#!/bin/bash
# =============================================================================
#  Helper functions for RPM package configuration.
# =============================================================================

install_package_configuration() {
    local package="$1"
    local permission="$2"

    local pkgs_source="${paths[current]}/.config/${package}"
    local pkgs_target="${paths[home]}/.config/${package}" 

    [[ -d "${pkgs_target}" ]] && comm_remove_items "${pkgs_target}"
    
    comm_copy_files_to_destination "${pkgs_source}" "${pkgs_target}"
    
    if [[ "${permission}" -eq 1 ]]; then
        comm_make_executable "${pkgs_target}"
    fi
}
