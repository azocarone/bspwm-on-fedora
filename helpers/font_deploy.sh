#!/bin/bash
# =============================================================================
#  Helper functions for font deployment of user and system fonts.
# =============================================================================

determine_sudo_command() {
    local key="$1"

    [[ $key == "system" ]] && echo "sudo " || echo ""
}

deploy_fonts_to_target() {
    local source="$1"
    local target="$2"
    local cmd_prefix="$3"

    ${cmd_prefix}mkdir -p "$target"
    ${cmd_prefix}cp -rv "$source"/* "$target"
    
    echo_check "Fonts deployed to ${target}."
}
