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
}

source ./helpers/aux_level_3.sh

expand_path() {
    local target="$1"
    local resolved_path

    case "$target" in
        ".")
            resolved_path="${paths[current]}"
            ;;
        "~")
            resolved_path="${paths[home]}"
            ;;
        "~/"*)
            # Remove the “~/” and add the path to home
            resolved_path="${paths[home]}/${target:2}"
            ;;
        /*)
            # Any absolute path is returned as is
            resolved_path="$target"
            ;;
        *)
            echo "Target not recognized: $target"
            return 1
            ;;
    esac

    echo "$resolved_path"
}

clone_repository() {
    local url="$1"
    local base_path="$2"
    
    local absolute_path=$(determine_clone_path "$url" "$base_path")

    if git clone --depth=1 "$url" "$absolute_path"; then
        echo "${absolute_path}"
    else
        echo -e "${bullets[error]} Error: cloning the ${colors[red]}${url}${colors[white]} repository."
        return 1
    fi
}

build_from_source() {
    local absolute_path="$1"
    local command="$2"
    
    local script_temp=$(mktemp)

    # Trap with anonymous function.
    trap 'rm -f "$script_temp"' EXIT 
    
    # Sub-shell so as not to alter or change the current working directory.
    ( 
    
        cd "$absolute_path" || {
            echo -e "${bullets[error]} Error: when changing to ${colors[red]}${absolute_path}${colors[white]} directory."
            return 1
        }

        # Implement a Heredocs
        cat > "$script_temp" <<EOF
#!/bin/bash
$command
EOF

        chmod +x "$script_temp"

        if ! ( "$script_temp" ); then
            echo -e "${bullets[error]} Error: when building the ${colors[red]}${absolute_path}${colors[white]} package."
            return 1
        fi
    )
}

deploy_executable() {
    local absolute_path="$1"
    local target="$2"
    
    local repo_name=$(basename "$absolute_path")
    local bin_file="$absolute_path/$repo_name"

    if has_install_script "$absolute_path"; then
        return
    fi

    if [[ -f "$bin_file" ]]; then
        copy_files_to_destination "$bin_file" "$target"
    fi
}

download_artifact(){
    local url="$1"
    local target="$2"

    local file=$(basename "$url")

    if [[ -f "$target/$file" ]]; then
        echo -e "${bullets[success]} The file ${colors[yellow]}${file}${colors[white]} already exists."
        return 1
    fi
        
    if sudo mkdir -p "$target" && sudo curl -L "$url" -o "$target/$file"; then
        echo -e "${bullets[check]} The file ${colors[green]}${file}${colors[white]} downloaded successfully."
    else
        echo -e "${bullets[error]} Error: failed to download the file ${colors[red]}${file}${colors[white]}."
        return 1
    fi
} 

remove_directory() {
    local cleanup="$1"
    
    if [[ -z "$cleanup" ]]; then
        echo -e "${bullets[error]} Error: no folder was provided for deletion."
        return 1
    fi

    if [[ ! -d "$cleanup" ]]; then
        echo -e "${bullets[error]} Error: the folder '${colors[red]}$cleanup${colors[white]}' does not exist or is not a directory."
        return 1
    fi

    rm -rf "$cleanup"
    
    if [[ $? -eq 0 ]]; then
        echo -e "${bullets[check]} The '${colors[green]}$cleanup${colors[white]}' folder has been successfully deleted."
    else
        echo -e "${bullets[error]} Error: the '${colors[red]}$cleanup${colors[white]}' folder could not be deleted."
        return 1
    fi
}


source ./helpers/aux_level_4.sh

determine_clone_path() {
    local url="$1"
    local base_path="${2:-${paths[current]}}"
    
    local absolute_path
    local repo_name=$(basename "${url}" .git)
    
    if [[ "${base_path}" == *"/." ]]; then
        # Case 1: If base_path ends in “/.”, do not add “/”.
        absolute_path="${base_path}${repo_name}"
    else
        # Case 2: In any other case, add “/”.
        absolute_path="${base_path}/${repo_name}"
    fi

    echo "${absolute_path}"
}

has_install_script() {
    local absolute_path="$1"
    local pattern="install*"

    if find "$absolute_path" -maxdepth 1 -name "$pattern" -type f | grep -q .; then
        return 0
    else
        return 1
    fi
}

process_asset() {
    local asset="$1"
    local target="$2"
    local copy_cmd="$3"

    if ! file_or_directory_exists "$asset"; then
        return 1
    fi

    if [[ -d "$asset" ]]; then
        $copy_cmd -rv "$asset" "$target"
    else
        $copy_cmd -v "$asset" "$target"
    fi
}

determine_copy_command() {
    local target="$1"
    [[ -e "$target" && ! -w "$target" ]] && echo "sudo cp" || echo "cp"
}

file_or_directory_exists() {
    local asset="$1"

    if [[ ! -e "$asset" ]]; then
        echo -e "${bullets[error]} Error: ${colors[red]}${asset}${colors[white]} is not a file or a directory."
        return 1
    fi

    return 0
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

