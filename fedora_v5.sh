#!/bin/bash

temporal() {
    echo -e "${NEWLINE}${WHITE} [${BLUE}i${WHITE}] Installing the powerlevel10k, fzf, sudo-plugin, and others for zsh."
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
    echo -e "${NEWLINE}${WHITE} [${BLUE}i${WHITE}] Installing bspwm cripts."
    cp -r scripts "${LOCALPATH}"
    chmod +x "${LOCALPATH}/scripts/"*.sh
    chmod +x "${LOCALPATH}/scripts/wall-scripts/"*.sh
}

installing_bspwm_themes() {
    echo -e "${NEWLINE}${WHITE} [${BLUE}i${WHITE}] Installing bspwm themes."
    cp -r .themes "${LOCALPATH}"
    for theme in Camila Esmeralda Nami Raven Ryan Simon Xavier Zenitsu; do
        chmod +x "${LOCALPATH}/.themes/${theme}/bspwmrc"
        chmod +x "${LOCALPATH}/.themes/${theme}/scripts/"*.sh
    done
}

clone_and_build() {
    local repo=$1
    local build_script=$2
    cd "${LOCALPATH}" || exit
    git clone "$repo"
    local repo_name=$(basename "$repo" .git)
    cd "$repo_name" || exit
    $build_script
    cd "${LOCALPATH}" || exit
    sudo rm -rf "$repo_name"
}

install_packages() {
    sudo dnf install -y "$@"
}

build_tty_clock() {
    install_packages ncurses ncurses-devel gcc
    clone_and_build "https://github.com/xorg62/tty-clock.git" "make && chmod +x tty-clock && sudo mv tty-clock /usr/local/bin/tty-clock"
}

build_i3lock_color() {
    install_packages autoconf automake cairo-devel fontconfig gcc libev-devel libjpeg-turbo-devel libXinerama libxkbcommon-devel libxkbcommon-x11-devel libXrandr pam-devel pkgconf xcb-util-image-devel xcb-util-xrm-devel
    clone_and_build "https://github.com/Raymo111/i3lock-color.git" "./build.sh && ./install-i3lock-color.sh"
}

build_betterlockscreen() {
    build_i3lock_color
    install_packages ImageMagick bc xdpyinfo xrandr xrdb xset dunst feh
    wget -qO- https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh | sudo bash -s system
}

install_missing_dependencies() {
    echo -e "${NEWLINE}${WHITE} [${BLUE}i${WHITE}] Installing missing dependencies."
    build_betterlockscreen
    install_packages rofi fira-code-fonts abattis-cantarell-fonts lxappearance nitrogen lsd zsh flameshot git net-tools xclip xdotool scrub bat openvpn feh pulseaudio-utils lolcat
    build_tty_clock
}

configure_package() {
    local package=$1
    local config_path=$2
    sudo rm -rf "${LOCALPATH}/.config/$package"
    cp -r "${RUTE}/.config/$package" "${LOCALPATH}/.config/$package"
    chmod +x "${LOCALPATH}/.config/$package/${config_path}"
}

configuring_packages() {
    echo -e "${NEWLINE}${WHITE} [${BLUE}i${WHITE}] Configuring packages."
    configure_package bspwm bspwmrc
    configure_package sxhkd sxhkdrc
    for package in kitty picom neofetch ranger cava polybar; do
        configure_package "$package" ""
    done
}

installing_fonts() {
    echo -e "${NEWLINE}${WHITE} [${BLUE}i${WHITE}] Installing fonts."
    sudo rm -rf "${LOCALPATH}/.fonts"
    cp -r ".fonts" "${LOCALPATH}"
    sudo cp -r ".fonts" "/usr/share/fonts"
    echo -e "${NEWLINE}${WHITE} [${BLUE}+${WHITE}] Installed fonts."
}

check_and_install() {
    local packages=("$@")
    local to_install=()
    for package in "${packages[@]}"; do
        if ! which "$package" >/dev/null; then
            echo -e "${WHITE} [${RED}-${WHITE}] ${package^^} is not installed, adding to install list"
            to_install+=("$package")
        else
            echo -e "${WHITE} [${BLUE}+${WHITE}] ${package^^} is already installed"
        fi
    done
    if [ ${#to_install[@]} -ne 0 ]; then
        sudo dnf update
        install_packages "${to_install[@]}"
    fi
}

banner() {
    clear
    echo -e "${NEWLINE}${WHITE} ╔───────────────────────────────────────────────╗"
    echo -e "${WHITE} |${CYAN} ██████╗ ███████╗██████╗ ██╗    ██╗███╗   ███╗${WHITE} |"
    echo -e "${WHITE} |${CYAN} ██╔══██╗██╔════╝██╔══██╗██║    ██║████╗ ████║${WHITE} |"
    echo -e "${WHITE} |${CYAN} ██████╔╝███████╗██████╔╝██║ █╗ ██║██╔████╔██║${WHITE} |"
    echo -e "${WHITE} |${CYAN} ██╔══██╗╚════██║██╔═══╝ ██║███╗██║██║╚██╔╝██║${WHITE} |"
    echo -e "${WHITE} |${CYAN} ██████╔╝███████║██║     ╚███╔███╔╝██║ ╚═╝ ██║${WHITE} |"
    echo -e "${WHITE} |${CYAN} ╚═════╝ ╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝     ╚═╝${WHITE} |"
    echo -e "${WHITE} ┖───────────────────────────────────────────────┙${NEWLINE}"
    echo -e "${WHITE} [${BLUE}i${WHITE}] bspwm-on-fedora | Scripts to install and configure a professional"
    echo -e "${WHITE} [${BLUE}i${WHITE}] bspwm environment on Fedora Linux Workstation."
    echo -e "${NEWLINE}${WHITE} [${BLUE}i${WHITE}] Hello ${RED}${USERNAME}${WHITE}, installation will begin soon."
}

colors() {
    WHITE='\033[1;37m'
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    CYAN='\033[1;36m'
    BLUE='\033[1;34m'
}

main() {
    colors
    banner
    echo -ne "${NEWLINE}${WHITE} [${BLUE}!${WHITE}] Do you want to continue with the installation? ([Y]/N) ▶ ${RED} "
    read -r quest
    if [[ $quest = Y ]]; then
        echo -e "${NEWLINE}${WHITE} [${BLUE}i${WHITE}] Starting installation process.${NEWLINE}"
        local essential_packages=(bspwm sxhkd kitty picom neofetch ranger cava polybar)
        check_and_install "${essential_packages[@]}"
        #installing_fonts
        #configuring_packages
        #install_missing_dependencies
        #installing_bspwm_themes
        #installing_bspwm_scripts
        #temporal
        echo -e "${NEWLINE}${WHITE} [${GREEN}+${WHITE}] Installation completed, please reboot to apply the configuration."
    else
        echo -e "${NEWLINE}${WHITE} [${RED}!${WHITE}] Installation aborted."
    fi
}

USERNAME=$(whoami)
LOCALPATH="/home/${USERNAME}"
RUTE=$(pwd)
NEWLINE=$'\n'

main