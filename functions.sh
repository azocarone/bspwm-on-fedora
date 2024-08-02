show_banner() {
    local banner_file="$1"

    clear

    if [[ -f "$banner_file" ]]; then
        echo -e "${colors[cyan]}" ; cat "$1"
    else
        echo -e "${bullets[error]} Banner file not found: $banner_file\n"
    fi

    echo -e "${bullets[info]} Scripts to install and configure a professional"
    echo -e "${bullets[info]} BSPWM environment on Fedora Linux Workstation.\n"
    echo -e "${bullets[info]} Hello ${colors[purple]}$(whoami)${colors[white]}, installation will begin soon.\n"
}

ask_installation_confirmation() {
    echo -ne "${bullets[question]} Do you want to continue with the installation [y/N]?: "
    tput setaf 1 ; read -r reply ; tput setaf 0

    [[ "$reply" == "y" ]]
}

update_and_install_rpm_packages(){
    local rpm_packages="$1"

    echo -e "${bullets[info]} Linux system update:\n"
    
    sudo dnf upgrade -y --refresh

    echo -e "${bullets[info]} Install RPM packages:\n"
    
    sudo dnf install -y ${rpm_packages}
}

install_git_packages(){
    local git_packages="$1"
    local install_dir="$2"

    echo -e "${bullets[info]} Deploy Git packages:\n"
    
    while read -r repo_url build_command; do
        local package_name=$(basename "$repo_url" .git)
        if git_clone_and_build "$repo_url" "$package_name" "$build_command"; then
            install_executable_to_path "$package_name" "$install_dir"
        fi
        remove_package_folder "$package_name"
    done <<< "$git_packages"
}

git_clone_and_build(){
    local repo_url="$1"
    local package_name="$2"
    local build_command="$3"
    local temp_script=$(mktemp)

    if ! git clone --depth=1 "$repo_url" "$package_name"; then
        echo "${bullets[error]} Error cloning repository: $repo_url"
        return 1
    fi

    cd "$package_name" || { echo "${bullets[error]} Error changing to directory: $package_name"; return 1; }

    echo "#!/bin/bash" > "$temp_script"
    echo "$build_command" >> "$temp_script"
    chmod +x "$temp_script"

    if ! ( "$temp_script" ); then
        echo "${bullets[error]} Error building package: $package_name"
        cd ..
        rm -rf "$package_name"
        return 1
    fi

    rm "$temp_script"
}

install_executable_to_path(){
    local package_name="$1"
    local install_dir="$2"
    local installer=$(locate_installer .)

    if [[ -z "$installer" ]] && [[ -f "$package_name" ]]; then
        copy_files_and_directories "$install_dir" "$package_name"
    fi
}

locate_installer(){
    local path="$1"

    find "$path" -type f -name 'install*' -print -quit
}

remove_package_folder(){
    local package_name="$1"

    cd ..
    rm -rf "$package_name"
}

copy_and_configure_packages() {
    local -n permission=$1
    
    echo -e "${bullets[info]} Copy and configure all packages:\n"
    
    for package in "${!permission[@]}"; do
        copy_config_and_set_permissions "$package" "${permission[$package]}"
    done
}

copy_config_and_set_permissions() {
    local package="$1"
    local need_permission="$2"
    local paths_dest="${paths[home]}/.config/$package" 
    local paths_source="${paths[current]}/.config/$package"

    if [[ -d "$paths_dest" ]]; then
        rm -rf "$paths_dest"
    fi

    copy_files_and_directories "$paths_dest" "$paths_source" 
    
    if [[ "${need_permission}" == 1 ]]; then
        make_executables "$paths_dest"
    fi
}

copy_assets_and_set_permissions() {
    local dest="$1"
    shift
    local assets=("$@")
    local copied_assets=()

    echo -e "${bullets[info]} Copy and set permissions:\n"

    copy_files_and_directories "$dest" "${assets[@]}"
    for asset in "${assets[@]}"; do
        copied_assets+=("${dest}/$(basename "$asset")")
    done
    make_executables "${copied_assets[@]}"
}

copy_files_and_directories() {
    local dest="$1"
    shift
    local assets=("$@")

    echo -e "${bullets[info]} Copying assets to $dest:\n"

    for asset in "${assets[@]}"; do
        if [[ -d "$asset" ]]; then
            cp -r "$asset" "$dest"
        elif [[ -f "$asset" ]]; then
            cp "$asset" "$dest"
        else
            echo "${bullets[error]} $asset is neither a file nor a directory"
            return 1
        fi
    done
}

make_executables() {
    local assets=("$@")

    echo -e "${bullets[info]} Set permission of execute:\n"

    for asset in "${assets[@]}"; do
        if [[ -f "$asset" ]]; then
            grep -Il '^#!' "$asset" && chmod +x "$asset"
        elif [[ -d "$asset" ]]; then
            find "$asset" -type f -exec grep -Il '^#!' {} \; -exec chmod +x {} \;
        else
            echo "${bullets[error]} $asset is neither a file nor a directory"
            return 1
        fi
    done
}

copy_fonts_to_directories() {
    local -n paths=$1
    local paths_source="${paths[source]}"

    echo -e "${bullets[info]} Copying fonts:\n"

    if [[ -d "$paths_source" ]]; then
        local order_keys=("user" "system")
        local cmd_prefix=""

        for key in "${order_keys[@]}"; do
            local destination="${paths[$key]}"

            [[ $key == "system" ]] && local cmd_prefix="sudo "
          
            ${cmd_prefix}mkdir -p "$destination"
            ${cmd_prefix}cp -r -v "$paths_source"/* "$destination"
            
            paths_source="$destination"

            echo -e "${bullets[success]} Fonts copied to $destination\n"
        done
    else
        echo -e "${bullets[error]} Source directory $paths_source does not exist.\n"
        return 1
    fi
}

# ----------------------------------

sin_nombre() {
    echo -e "${bullets[info]} Installing the powerlevel10k, fzf, sudo-plugin, and others for the normal user"
    
    cd "${paths[current]}"
    cp .zshrc "${paths[home]}"
    cp .p10k.zsh "${paths[home]}"

    cd /usr/share
    sudo mkdir -p zsh-sudo
    cd zsh-sudo
    sudo wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh

    cd
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    
    cd "${paths[home]}"/scripts
    git clone https://github.com/charitarthchugh/shell-color-scripts.git
    sudo rm -rf "${paths[home]}"/scripts/shell-color-scripts/colorscripts
    sudo rm -rf "${paths[home]}"/scripts/shell-color-scripts/colorscript.sh
    cd "${paths[home]}"/scripts
    mv colorscripts colorscript.sh "${paths[home]}"/scripts/shell-color-scripts
    chmod +x "${paths[home]}"/scripts/shell-color-scripts/colorscript.sh
    cd "${paths[home]}"/scripts/shell-color-scripts/colorscripts
    chmod +x *

    cd
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    cd "${paths[home]}"/scripts
    git clone https://github.com/pipeseroni/pipes.sh.git
}