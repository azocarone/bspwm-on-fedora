#!/bin/bash

colors() {
    WHITE='\033[1;37m'
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    CYAN='\033[1;36m'
    BLUE='\033[1;34m'
}

banner() {
    echo -e "\n${WHITE} ╔───────────────────────────────────────────────╗"
    echo -e "${WHITE} |${CYAN} ██████╗ ███████╗██████╗ ██╗    ██╗███╗   ███╗${WHITE} |"
    echo -e "${WHITE} |${CYAN} ██╔══██╗██╔════╝██╔══██╗██║    ██║████╗ ████║${WHITE} |"
    echo -e "${WHITE} |${CYAN} ██████╔╝███████╗██████╔╝██║ █╗ ██║██╔████╔██║${WHITE} |"
    echo -e "${WHITE} |${CYAN} ██╔══██╗╚════██║██╔═══╝ ██║███╗██║██║╚██╔╝██║${WHITE} |"
    echo -e "${WHITE} |${CYAN} ██████╔╝███████║██║     ╚███╔███╔╝██║ ╚═╝ ██║${WHITE} |"
    echo -e "${WHITE} |${CYAN} ╚═════╝ ╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝     ╚═╝${WHITE} |"
    echo -e "${WHITE} ┖───────────────────────────────────────────────┙\n"
    echo -e "${WHITE} [${BLUE}i${WHITE}] Scripts to install and configure a professional"
    echo -e "${WHITE} [${BLUE}i${WHITE}] bspwm environment on Fedora Linux Workstation."
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Hello ${RED}$(whoami)${WHITE}, installation will begin soon."
}

check_missing_rpm_packages() {
    
    # Receive positional arguments in a local array.
    local packages=("${@}")
    
    local missing=()
    
    # "${packages[@]}" Expands the array as a list of items separated by space.
    for package in "${packages[@]}"; do
        if ! command -v "$package" >/dev/null; then
            missing+=("$package")
        fi
    done
    
    echo "${missing[@]}"
}

install_rpm_packages_rpm() {
    local missing_packages="$@"
    
    # [[ -n "$missing_packages" ]] Check to see if the variable isn't empty.
    if [[ -n $missing_packages ]]; then
        sudo dnf install -y $missing_packages
    fi
}

install_packages_from_git() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Installing packages from git.\n"

    git_packages=(
        "https://github.com/Raymo111/i3lock-color.git ./build.sh && ./install-i3lock-color.sh"
        "https://github.com/betterlockscreen/betterlockscreen.git sudo ./install.sh system"
        "https://github.com/xorg62/tty-clock.git make && chmod +x tty-clock"
    )

    for git_package in "${git_packages[@]}"; do
        
        # Extract the repository URL.
        repo_url="${git_package%% *}"
        
        # Extract the build command.
        build_command="${git_package#"$repo_url "}"
        
        deploy_git_package "$repo_url" "$build_command"
    done
}

deploy_git_package() {
    local repo_url="$1"
    local build_command="$2"
    
    if ! git clone --depth=1 "$repo_url"; then
        echo "Error when cloning $repo_url" exit 1
    else
        local package_name=$(basename "$repo_url" .git)
        cd "$package_name"
        if ! eval "$build_command"; then
            echo "Error when building $package_name" exit 1 
        else
            installation_files=$(find -name "install*")
            if [ -z $installation_files ]; then
                sudo mv "${package_name}" /usr/local/bin/
            fi
            
            #Back to LOCALPATH
            cd -
            
            sudo rm -rf "${package_name}"
        fi
    fi
}

copy_fonts() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Copying fonts."
    cp -r ".fonts" "${LOCALPATH}"
    sudo mkdir -p /usr/local/share/fonts && sudo cp -r ~/.fonts/* /usr/local/share/fonts
    echo -e "\n${WHITE} [${BLUE}+${WHITE}] Copied fonts."
}

# -------------

temporal() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Installing the powerlevel10k, fzf, sudo-plugin, and others for zsh."
    sudo rm -rf "${LOCALPATH}/.zsh"
    cp -r .zsh "${LOCALPATH}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k
    echo 'source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    cp -r .oh-my-zsh "${LOCALPATH}"
    cp .zshrc "${LOCALPATH}"
    cp .p10k.zsh "${LOCALPATH}"
    cp -r .scripts "${LOCALPATH}"
}

installing_bspwm_scripts() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Installing bspwm cripts."
    cp -r scripts "${LOCALPATH}"
    chmod +x "${LOCALPATH}/scripts/"*.sh
    chmod +x "${LOCALPATH}/scripts/wall-scripts/"*.sh
}

installing_bspwm_themes() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Installing bspwm themes."
    cp -r .themes "${LOCALPATH}"
    for theme in Camila Esmeralda Nami Raven Ryan Simon Xavier Zenitsu; do
        chmod +x "${LOCALPATH}/.themes/${theme}/bspwmrc"
        chmod +x "${LOCALPATH}/.themes/${theme}/scripts/"*.sh
    done
}

configure_package() {
    local package=$1
    local config_path=$2
    sudo rm -rf "${LOCALPATH}/.config/$package"
    cp -r "${RUTE}/.config/$package" "${LOCALPATH}/.config/$package"
    chmod +x "${LOCALPATH}/.config/$package/${config_path}"
}

configuring_packages() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Configuring packages."
    configure_package bspwm bspwmrc
    configure_package sxhkd sxhkdrc
    for package in kitty picom neofetch ranger cava polybar; do
        configure_package "$package" ""
    done
}

# -------------

main() {
    clear
    colors
    banner
    echo -ne "\n${WHITE} [${BLUE}!${WHITE}] Do you want to continue with the installation?: ([y]/n) ▶\t"
    tput setaf 1
    read -r quest
    tput setaf 0

    if [[ $quest = y ]]; then
        echo -e "\n${WHITE} [${BLUE}i${WHITE}] Starting installation process:\n" 
        
        sudo dnf upgrade -y --refresh
        mapfile -t essential_packages < 'packages.txt'

        # It passes the array as positional arguments and captures the output of the function in the variable.
        local missing_packages=$(check_missing_rpm_packages "${essential_packages[@]}")
      
        install_rpm_packages_rpm $missing_packages
        install_packages_from_git
        copy_fonts
        #configuring_packages
        #installing_bspwm_themes
        #installing_bspwm_scripts
        #temporal

        echo -e "\n${WHITE} [${GREEN}+${WHITE}] Installation completed, please reboot to apply the configuration."
    else
        echo -e "\n${WHITE} [${RED}!${WHITE}] Installation aborted."
    fi
}

LOCALPATH="/home/${USERNAME}"
RUTE=$(pwd

main