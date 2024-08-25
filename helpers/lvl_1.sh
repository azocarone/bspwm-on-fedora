source ./helpers/lvl_2.sh

display_installation_banner() {
    local banner="$1"

    clear
    
    if [[ ! -f "$banner" ]]; then
        echo -e "${bullets[error]} Error: ${colors[red]}${banner}${colors[white]} file not found."
        return 1
    fi

    echo -e "${colors[cyan]}" && cat "$banner"
    echo -e "${bullets[info]} Scripts to install and configure a professional,"
    echo -e "     BSPWM environment on Fedora Workstation."
    echo -e "${bullets[info]} Hello, ${colors[purple]}${USERNAME}${colors[white]}: deploy will begin soon."
}

read_user_confirmation() {
    local reply
    
    read -rp "${bullets[question]} Do you want to continue with the installation [y/n]?: " reply
    
    echo "${reply,,}" #  Convert to lowercase ",," and return the answer
}

handle_git_repository() {
    local repo_url="$1"
    local target_dir="$2"
    local build_command="$3"
    local binary_name="$4"
    local base_path repo_path

    base_path=$(expand_path "$target_dir")
    repo_path=$(clone_repository "${repo_url}" "${base_path}")

    [[ -n ${build_command} ]] && build_from_source "${repo_path}" "${build_command}"
    [[ -n ${binary_name} ]] && deploy_executable "${repo_path}" "${binary_name}"

    echo "${repo_path}"
}

handle_download_artifact() {
    local artifact_url="$1"
    local target_dir="$2"

    local base_path
    base_path=$(expand_path "$target_dir")
    download_artifact "${artifact_url}" "${base_path}"
}

handle_remove() {
    local dir_path="$1"
    [[ -n ${dir_path} ]] && remove_items "$dir_path"
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
    
    echo -e "${bullets[check]} Fonts deployed to ${colors[green]}$target${colors[white]}"
}

copy_files_to_destination() {
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    local copy_cmd

    echo -e "${bullets[info]} Copy assets from directories or files:"

    copy_cmd=$(determine_copy_command "$target")

    for asset in "${assets[@]}"; do
        process_asset "$asset" "$target" "$copy_cmd" || return 1
    done
}

generate_copied_assets() {
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    local -a copied_assets=()
    
    for asset in "${assets[@]}"; do
        copied_assets+=("$target/$(basename "$asset")")
    done

    echo "${copied_assets[@]}"
}

make_executable() {
    local assets=("$@")

    echo -e "${bullets[info]} Sets execution permission:"

    for asset in "${assets[@]}"; do
        if ! file_or_directory_exists "$asset"; then
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
    local home_scripts="${paths[home]}/scripts"
    local color_scripts="${home_scripts}/shell-color-scripts"

    remove_items "${color_scripts}/colorscripts" "${color_scripts}/colorscript.sh"
    
    mv "${home_scripts}/colorscripts" "$color_scripts"
    mv "${home_scripts}/colorscript.sh" "$color_scripts"
    
    make_executable "${color_scripts}/colorscripts" "${color_scripts}/colorscript.sh"
}
