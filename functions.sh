display_banner() {
    local banner_file="$1"

    clear

    if [ -f "$banner_file" ]; then
        echo -e "${colors[cyan]}" ; cat "$1"
    else
        echo -e "${bullets[error]} Banner file not found: $banner_file\n"
    fi

    echo -e "${bullets[info]} Scripts to install and configure a professional"
    echo -e "${bullets[info]} BSPWM environment on Fedora Linux Workstation.\n"
    echo -e "${bullets[info]} Hello ${colors[purple]}$(whoami)${colors[white]}, installation will begin soon.\n"
}

confirm_installation() {
    echo -ne "${bullets[question]} Do you want to continue with the installation [y/N]?: "
    tput setaf 1
    read -r reply
    tput setaf 0

    if [ "$reply" = "y" ]; then
        return 0
    else
        return 1
    fi
}

install_rpm_packages(){
    local rpm_packages="$1"

    echo -e "${bullets[info]} Linux System Update:\n"
    sudo dnf upgrade -y --refresh

    echo -e "${bullets[info]} Installing rpm packages:\n"
    sudo dnf install -y ${rpm_packages}
}

deploy_git_packages(){
    local git_packages="$1"
    local install_dir="$2"

    echo -e "${bullets[info]} Installing packages from git:\n"
    
    while read -r repo_url build_command; do
        local package_name=$(basename "$repo_url" .git)
        if clone_and_build "$repo_url" "$package_name" "$build_command"; then
            copy_executable_to_install_dir "$package_name" "$install_dir"
        fi
        cleanup_package_dir "$package_name"
    done <<< "$git_packages"
}

clone_and_build(){
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
    return 0
}

copy_executable_to_install_dir(){
    local package_name="$1"
    local install_dir="$2"
    local installer=$(find_installer .)

    if [ -z "$installer" ] && [ -f "$package_name" ]; then
        sudo cp "$package_name" "$install_dir"
    fi
}

find_installer(){
    local dir="$1"

    find "$dir" -type f -name 'install*' -print -quit
}

cleanup_package_dir(){
    local package_name="$1"

    cd ..
    rm -rf "$package_name"
}

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

copy_all_package_configurations() {
    local packages=(bspwm sxhkd kitty picom neofetch ranger cava polybar)

    echo -e "${bullets[info]} Copying packages configurations.\n"
    
    for package in "${packages[@]}"; do
        copy_and_configure_package "$package"
    done
}

copy_and_configure_package() {
    local package="$1"
    local need_permissions=(bspwm sxhkd polybar)
    
    if [ -d "${HOME_DIR}/.config/$package" ]; then
        rm -rf "${HOME_DIR}/.config/$package"
    fi

    cp -r "${CURRENT_DIR}/.config/$package" "${HOME_DIR}/.config/$package"
    
    if [[ "${need_permissions[@]}" =~ "$package" ]]; then
        set_executable_permissions "${HOME_DIR}/.config/$package" # Base folder
    fi
}

set_executable_permissions() {
    local base_folder="$1"
    
    find "$base_folder" -type f | while read -r patch_file; do
        if head -n 1 "$patch_file" | grep -q '^#!'; then
            chmod +x "$patch_file"
        fi
    done
}

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

copy_bspwm_scripts() {
    echo -e "${WHITE} [${BLUE}i${WHITE}] Copying bspwm scripts.\n"

    cp -r scripts "${HOME_DIR}"
    
    chmod +x "${HOME_DIR}/scripts/"*.sh
    chmod +x "${HOME_DIR}/scripts/wall-scripts/"*.sh
}

copy_bspwm_themes() {
    echo -e "${WHITE} [${BLUE}i${WHITE}] Copying bspwm themes.\n"

    cp -r .themes "${HOME_DIR}"
    
    for theme in Camila Esmeralda Nami Raven Ryan Simon Xavier Zenitsu; do
        chmod +x "${HOME_DIR}/.themes/${theme}/bspwmrc"
        chmod +x "${HOME_DIR}/.themes/${theme}/scripts/"*.sh
    done
}    

copy_fonts() {
    echo -e "${WHITE} [${BLUE}i${WHITE}] Copying fonts."

    cp -r ".fonts" "${HOME_DIR}"
    
    sudo mkdir -p /usr/local/share/fonts && sudo cp -r ~/.fonts/* /usr/local/share/fonts
}

# -------------

temporal() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Installing the powerlevel10k, fzf, sudo-plugin, and others for zsh."
    
    sudo rm -rf "${HOME_DIR}/.zsh"
    
    cp -r .zsh "${HOME_DIR}"
    
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k
    
    echo 'source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
    
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    cp -r .oh-my-zsh "${HOME_DIR}"
    cp .zshrc "${HOME_DIR}"
    cp .p10k.zsh "${HOME_DIR}"
    cp -r .scripts "${HOME_DIR}"
}
