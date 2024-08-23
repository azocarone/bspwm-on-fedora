source ./helpers/aux_level_2.sh

display_installation_banner() {
    local banner="$1"

    clear

    if [[ ! -f "$banner" ]]; then
        echo -e "${bullets[error]} Error: ${colors[red]}${banner}${colors[white]} file not found."
        return 1
    fi

    echo -e "${colors[cyan]}"
    cat "$banner"
    
    echo -e "${bullets[info]} Scripts to install and configure a professional,"
    echo -e "     BSPWM environment on Fedora Workstation."
    echo -e "${bullets[info]} Hello, ${colors[purple]}${USERNAME}${colors[white]}: deploy will begin soon."
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
    [[ -n ${dir_path} ]] && remove_directory "$dir_path"
}

install_package_configuration() {
    local package="$1"
    local permission="$2"

    local pkgs_source="${paths[current]}/.config/${package}"
    local pkgs_target="${paths[home]}/.config/${package}" 

    [[ -d "${pkgs_target}" ]] && remove_directory "${pkgs_target}"
    
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

generate_copied_assets() {
    local -a assets=("${@:1:$#-1}")
    local target="${!#}"

    local -a copied_assets=()
    
    for asset in "${assets[@]}"; do
        copied_assets+=("$target/$(basename "$asset")")
    done

    echo "${copied_assets[@]}"
}

handle_color_scripts(){
    local home_scripts="${paths[home]}/scripts"
    local color_scripts="${home_scripts}/shell-color-scripts"

    rm -rf "${color_scripts}/colorscripts" "${color_scripts}/colorscript.sh"
    
    mv "${home_scripts}/colorscripts" "$color_scripts"
    mv "${home_scripts}/colorscript.sh" "$color_scripts"
    
    make_executable "${color_scripts}/colorscripts" "${color_scripts}/colorscript.sh"
    #chmod +x "${color_scripts}/colorscript.sh" "${color_scripts}/colorscripts/"*
}
