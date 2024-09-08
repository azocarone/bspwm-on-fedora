#!/bin/bash
# =============================================================================
#  Helper functions for ZSH assets setup.
# =============================================================================

handle_color_scripts(){
    local home_scripts="$1"
    
    local color_scripts="${home_scripts}/shell-color-scripts"
    local items=("${color_scripts}/colorscripts" "${color_scripts}/colorscript.sh")

    comm_remove_items "${items[@]}"
    
    mv "${home_scripts}/colorscripts" "${home_scripts}/colorscript.sh" "$color_scripts"
    
    comm_make_executable "${items[@]}"
}
