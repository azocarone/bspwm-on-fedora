#!/bin/bash

define_colors() {
    WHITE='\033[1;37m'
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    CYAN='\033[1;36m'
    BLUE='\033[1;34m'
}

display_banner() {
    local banner_file="$1"

    if [ -f "$banner_file" ]; then
        echo -e "${CYAN}" ; cat "$1"
    else
        echo -e "${RED}Banner file not found: $banner_file\n"
    fi
      
    echo -e "${WHITE} [${BLUE}i${WHITE}] Scripts to install and configure a professional"
    echo -e "${WHITE} [${BLUE}i${WHITE}] BSPWM environment on Fedora Linux Workstation.\n"
    echo -e "${WHITE} [${BLUE}i${WHITE}] Hello ${RED}$(whoami)${WHITE}, installation will begin soon.\n"
}

get_list_rpm_packages() {
    local yaml_file="$1"
    local list_rpm_packages=$(awk '
        /^[^:]+:$/ { in_list=1; next }
        /^\s*$/ { in_list=0 }
        /^\s*-\s+/ && in_list { print $2 }
    ' "$yaml_file")
    
    echo "$list_rpm_packages"
}

get_list_git_packages(){
    local yaml_file="$1"
    local list_git_packages=$(awk '
        /^\s*repo_url:/ {
            repo_url=gensub(/.*repo_url: /, "", 1)
            gsub(/"/, "", repo_url)
        }
        /^\s*build_command:/ {
            build_command=gensub(/.*build_command: /, "", 1)
            gsub(/"/, "", build_command)
            print repo_url, build_command
        }
    ' "$yaml_file")
    
    echo "$list_git_packages"
}

install_rpm_packages_from_list(){
    local list_rpm_packages="$1"

    echo -e "${WHITE} [${BLUE}i${WHITE}] Installing rpm packages:\n"
    
    sudo dnf upgrade -y --refresh \
        | sudo dnf install -y ${list_rpm_packages}
}

deploy_git_packages_from_list(){
    local list_git_packages="$1"
    local install_dir="$2"

    echo -e "${WHITE} [${BLUE}i${WHITE}] Installing packages from git.\n"
    
    while read -r repo_url build_command; do
        local package_name=$(basename "$repo_url" .git)
        if clone_and_build "$repo_url" "$package_name" "$build_command"; then
            copy_executable_to_install_dir "$package_name" "$install_dir"
        fi
        cleanup_package_dir "$package_name"
    done <<< "$list_git_packages"
}

clone_and_build(){
    local repo_url="$1"
    local package_name="$2"
    local build_command="$3"
    local temp_script=$(mktemp)

    if ! git clone --depth=1 "$repo_url" "$package_name"; then
        echo "Error cloning repository: $repo_url"
        return 1
    fi

    cd "$package_name" || { echo "Error changing to directory: $package_name"; return 1; }

    echo "#!/bin/bash" > "$temp_script"
    echo "$build_command" >> "$temp_script"
    chmod +x "$temp_script"

    if ! ( "$temp_script" ); then
        echo "Error building package: $package_name"
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

# ---------------------------------

copy_packages_configurations() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Copying packages configurations.\n"
    
    local packages=(bspwm sxhkd kitty picom neofetch ranger cava polybar)
    
    for package in "${packages[@]}"; do
        copy_package_settings "$package"
    done
}

copy_package_settings() {
    local package="$1"
    
    sudo rm -rf "${HOME_DIR}/.config/$package"
    
    cp -r "${CURRENT_DIR}/.config/$package" "${HOME_DIR}/.config/$package"
    
    if $package == "bspwm" || $package == "sxhkd" || $package == "polybar"; then
        local base_folder="${HOME_DIR}/.config/$package"
        
        grant_permission_exe "$base_folder"
    fi
}

grant_permission_execute(){
    local base_folder="$1"
    
    for patch_file in "$base_folder"/**/*.*; do
        if is_bash_script "$patch_file"; then
            chmod +x "$patch_file"
        fi
    done
}

is_bash_script() {
    local patch_file="$1"
    local shebang=$(head -n 1 "$patch_file")
    
    if [[ $shebang == "#!"* ]]; then
        return 0
    else
        return 1
    fi
}

copy_bspwm_scripts() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Copying bspwm scripts.\n"

    cp -r scripts "${HOME_DIR}"
    
    chmod +x "${HOME_DIR}/scripts/"*.sh
    chmod +x "${HOME_DIR}/scripts/wall-scripts/"*.sh
}

copy_bspwm_themes() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Copying bspwm themes.\n"

    cp -r .themes "${HOME_DIR}"
    
    for theme in Camila Esmeralda Nami Raven Ryan Simon Xavier Zenitsu; do
        chmod +x "${HOME_DIR}/.themes/${theme}/bspwmrc"
        chmod +x "${HOME_DIR}/.themes/${theme}/scripts/"*.sh
    done
}    

copy_fonts() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Copying fonts."

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

# ----------

main() {
    HOME_DIR="/home/${USERNAME}"
    CURRENT_DIR=$(pwd)
    local banner_file="resources/banner.txt"
    local install_dir="/usr/local/bin/"

    clear
    define_colors
    display_banner "$banner_file"
    
    echo -ne "${WHITE} [${BLUE}?${WHITE}] Do you want to continue with the installation?: ([y]/n) ▶\t"
    
    tput setaf 1
    read -r reply
    tput setaf 0

    if [[ $reply == 'y' ]]; then
        local list_rpm_packages=$(get_list_rpm_packages "rpm_packages.yaml")
        local list_git_packages=$(get_list_git_packages "git_packages.yaml")

        echo -e "${WHITE} [${BLUE}i${WHITE}] Starting the installation process.\n" 

        install_rpm_packages_from_list "$list_rpm_packages"
        deploy_git_packages_from_list "$list_git_packages" "$install_dir"

        #copy_packages_configurations
        #copy_bspwm_scripts
        #copy_bspwm_themes
        #copy_fonts
        #temporal

        echo -e "\n${WHITE} [${GREEN}+${WHITE}] Installation completed, please reboot to apply the configuration."
    else
        echo -e "\n${WHITE} [${RED}!${WHITE}] Installation aborted."
    fi
}

main