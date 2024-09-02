handle_git_repository() {
    local repo_url="$1"
    local target_dir="$2"
    local build_command="$3"
    local target_bin="$4"
    
    local base_path=$(expand_path "$target_dir")
    
    local repo_path

    if ! repo_path=$(clone_repository "$repo_url" "$base_path"); then
        return 1 # Error already handled in clone_repository.
    fi
    
    if ! build_from_source "$repo_path" "$build_command"; then
        return 1 # Error already handled in build_from_source.
    fi

    if ! deploy_executable "$repo_path" "$target_bin"; then
        return 1  # Error already handled in deploy_executable.
    fi

    echo "$repo_path"
}

handle_download_artifact() {
    local repo_url="$1"
    local target_dir="$2"

    local base_path

    base_path=$(expand_path "$target_dir")
    download_artifact "${repo_url}" "${base_path}"
}

handle_remove() {
    local remove_repo="$1"
    local repo_path="$2"
    
    if [[ "$remove_repo" -eq 1 && -n "$repo_path" ]]; then
        remove_items "$repo_path" || return 1
    fi

    return 0
}

install_package_configuration() {
    local package="$1"
    local permission="$2"

    local pkgs_source="${paths[current]}/.config/${package}"
    local pkgs_target="${paths[home]}/.config/${package}" 

    [[ -d "${pkgs_target}" ]] && remove_items "${pkgs_target}"
    
    copy_files_to_destination "${pkgs_source}" "${pkgs_target}"
    
    [[ "${permission}" -eq 1 ]] && make_executable "${pkgs_target}"
}

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

copy_files_to_destination() {
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    local copy_cmd asset

    echo_info "Copy assets from directories or files:"

    copy_cmd=$(determine_copy_command "$target")

    for asset in "${assets[@]}"; do
        process_asset "$asset" "$target" "$copy_cmd" || return 1
    done
}

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

make_executable() {
    local assets=("$@")

    local asset

    echo_info "Sets execution permission:"

    for asset in "${assets[@]}"; do
        if ! directory_or_file_exists "$asset"; then
            return 1
        fi

        if [[ -d "$asset" ]]; then
            find "$asset" -type f -exec grep -Il '^#!' {} \; -exec chmod +x {} \;
        else
            grep -Il '^#!' "$asset" && chmod +x "$asset"
        fi
    done
}

handle_color_scripts(){
    local home_scripts="$1"
    
    local color_scripts="${home_scripts}/shell-color-scripts"
    local items=("${color_scripts}/colorscripts" "${color_scripts}/colorscript.sh")

    remove_items "${items[@]}"
    
    mv "${home_scripts}/colorscripts" "${home_scripts}/colorscript.sh" "$color_scripts"
    
    make_executable "${items[@]}"
}
