# =============================================================================
#  Project Name: bspwm-on-fedora
#  Description : Scripts to install and configure a professional 
#                BSPWM environment on Fedora Linux Workstation. 
# -----------------------------------------------------------------------------
#  Author      : José AZOCAR (azocarone)
#  Created on  : 2024-09-06
#  Version     : RC3
# -----------------------------------------------------------------------------
#  Usage       : Aux. funcs. for font deployment of user and system fonts
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
