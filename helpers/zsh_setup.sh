# =============================================================================
#  Project Name: bspwm-on-fedora
#  Description : Scripts to install and configure a professional 
#                BSPWM environment on Fedora Linux Workstation. 
# -----------------------------------------------------------------------------
#  Author      : José AZOCAR (azocarone)
#  Created on  : 2024-09-06
#  Version     : RC3
# -----------------------------------------------------------------------------
#  Usage       : Aux. funcs. for ZSH assets setup
# =============================================================================

handle_color_scripts(){
    local home_scripts="$1"
    
    local color_scripts="${home_scripts}/shell-color-scripts"
    local items=("${color_scripts}/colorscripts" "${color_scripts}/colorscript.sh")

    comm_remove_items "${items[@]}"
    
    mv "${home_scripts}/colorscripts" "${home_scripts}/colorscript.sh" "$color_scripts"
    
    comm_make_executable "${items[@]}"
}
