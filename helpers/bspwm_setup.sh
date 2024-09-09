#!/bin/bash
# =============================================================================
#  Helper functions for bspwm assets setup.
# =============================================================================

bspwm_generate_copied() {
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    local asset
    local -a copied_assets=()
    
    for asset in "${assets[@]}"; do
        copied_assets+=("$target/$(basename "$asset")")
    done

    echo "${copied_assets[@]}"
}
