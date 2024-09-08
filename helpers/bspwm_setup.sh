#!/bin/bash
# =============================================================================
#  Helper functions for bspwm assets setup.
# =============================================================================

generate_copied_assets() {
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    local asset
    local -a copied_assets=()
    
    for asset in "${assets[@]}"; do
        copied_assets+=("$target/$(basename "$asset")")
    done

    echo "${copied_assets[@]}"
}
