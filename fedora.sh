#!/bin/bash

define_colors() {
    WHITE='\033[1;37m'
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    CYAN='\033[1;36m'
    BLUE='\033[1;34m'
}

display_banner() {
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

install_rpm_packages() {
    local yaml_file="$1"
    
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Installing rpm packages.\n"

    sudo dnf upgrade -y --refresh

    awk '
        /^[^:]+:$/ { in_list=1; next }
        /^\s*$/ { in_list=0 }
        /^\s*-\s+/ && in_list { print $2 }
    ' "$yaml_file" | xargs sudo dnf install -y
}

install_packages_from_git() {
    local yaml_file="$1"

    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Installing packages from git.\n"
    
    awk '
        /^\s*repo_url:/ {
            repo_url = substr($0, index($0, $2))
            gsub(/"/, "", repo_url)
        }
        /^\s*build_command:/ {
            build_command = substr($0, index($0, $2))
            gsub(/"/, "", build_command)
            print repo_url, build_command
        }
    ' "$yaml_file" | while read -r repo_url build_command; do
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
            local installation_files=$(find -name "install*")
            if [ -z $installation_files ]; then # Aqui hay un detalle: ./fedora.sh: línea 72: [: ./install-i3lock-color.sh: se esperaba un operador binario
                sudo mv "${package_name}" /usr/local/bin/
            fi
            
            #Back to LOCALPATH
            cd -
            
            sudo rm -rf "${package_name}"
        fi
    fi
}

copy_packages_configurations() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Copying packages configurations.\n"
    
    local packages=(bspwm sxhkd kitty picom neofetch ranger cava polybar)
    
    for package in "${packages[@]}"; do
        copy_package_settings "$package"
    done
}

copy_package_settings() {
    local package="$1"
    
    sudo rm -rf "${LOCALPATH}/.config/$package"
    
    cp -r "${RUTE}/.config/$package" "${LOCALPATH}/.config/$package"
    
    if $package == "bspwm" || $package == "sxhkd" || $package == "polybar"; then
        local base_folder="${LOCALPATH}/.config/$package"
        grant_permission_execute "$base_folder"
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

    cp -r scripts "${LOCALPATH}"
    chmod +x "${LOCALPATH}/scripts/"*.sh
    chmod +x "${LOCALPATH}/scripts/wall-scripts/"*.sh
}

copy_bspwm_themes() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Copying bspwm themes.\n"

    cp -r .themes "${LOCALPATH}"
    for theme in Camila Esmeralda Nami Raven Ryan Simon Xavier Zenitsu; do
        chmod +x "${LOCALPATH}/.themes/${theme}/bspwmrc"
        chmod +x "${LOCALPATH}/.themes/${theme}/scripts/"*.sh
    done
}

copy_fonts() {
    echo -e "\n${WHITE} [${BLUE}i${WHITE}] Copying fonts."

    cp -r ".fonts" "${LOCALPATH}"
    sudo mkdir -p /usr/local/share/fonts && sudo cp -r ~/.fonts/* /usr/local/share/fonts
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

# -------------

main() {
    clear
    define_colors
    display_banner
    
    echo -ne "\n${WHITE} [${BLUE}!${WHITE}] Do you want to continue with the installation?: ([y]/n) ▶\t"
    
    tput setaf 1
    read -r quest
    tput setaf 0

    if [[ $quest = y ]]; then
        echo -e "\n${WHITE} [${BLUE}i${WHITE}] Starting installation process:\n" 
        
        install_rpm_packages "rpm_packages.yaml"
        install_packages_from_git "from_git.yaml"
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

LOCALPATH="/home/${USERNAME}"   # /home/azocarone
RUTE=$(pwd)                     # /home/azocarone/Dev/bspwm-on-fedora

main