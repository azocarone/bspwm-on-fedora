#!/bin/bash

# COLOR USE THE SCRIPT
Black='\033[1;30m'
Red='\033[1;31m'
Green='\033[1;32m'
Yellow='\033[1;33m'
Blue='\033[1;34m'
Purple='\033[1;35m'
Cyan='\033[1;36m'
White='\033[1;37m'
NC='\033[0m'
blue='\033[0;34m'
white='\033[0;37m'
lred='\033[0;31m'
IWhite="\[\033[0;97m\]"

# VARIABLE DATABASE AND OTHER THINGS
USERNAME=$(whoami)
LOCALPATH="/home/${USERNAME}"
KERNEL=$(uname -r)
DISTRIBUTION=$(uname -o)
HOST=$(uname -n)
BIT=$(uname -m)
RUTE=$(pwd)

# SCRIPT PRESENTATION
banner () {
echo -e "${White} ╔───────────────────────────────────────────────╗                 	"
echo -e "${White} |${Cyan} ██████╗ ███████╗██████╗ ██╗    ██╗███╗   ███╗${White} |      "
echo -e "${White} |${Cyan} ██╔══██╗██╔════╝██╔══██╗██║    ██║████╗ ████║${White} |      "
echo -e "${White} |${Cyan} ██████╔╝███████╗██████╔╝██║ █╗ ██║██╔████╔██║${White} |      "
echo -e "${White} |${Cyan} ██╔══██╗╚════██║██╔═══╝ ██║███╗██║██║╚██╔╝██║${White} |	"
echo -e "${White} |${Cyan} ██████╔╝███████║██║     ╚███╔███╔╝██║ ╚═╝ ██║${White} |	"
echo -e "${White} |${Cyan} ╚═════╝ ╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝     ╚═╝${White} |	"
echo -e "${White} ┖───────────────────────────────────────────────┙			"
echo ""
echo -e "${White} [${Blue}i${White}] Hello ${Red}${USERNAME}${White}, This is the bspwm installation script for kali linux"
}

# INSTALLATION OF MISSING DEPENDENCIES
missing_dependencies () {
echo ""
echo -e "${White} [${Blue}i${White}] Step 9 installing missing dependencies"
sleep 2
echo ""
sudo apt install rofi fonts-firacode fonts-cantarell lxappearance nitrogen lsd betterlockscreen flameshot git net-tools xclip xdotool -y
echo ""
sudo apt install scrub bat tty-clock openvpn feh -y
echo ""
}

# INSTALL BSPWM KALI LINUX SETUP
setup () {
clear
echo ""
banner
sleep 1
echo -ne "${White} [${Blue}!${White}] Do you want to continue with the installation? Y|N ▶ ${Red}"
read quest
if [ $quest = Y ]; then
	echo ""
	echo -e "${White} [${Blue}i${White}] Step 1 checking if bspwm and sxhkd are installed"
	sleep 2
	if which bspwm >/dev/null; then
		echo ""
		echo -e "${White} [${Blue}+${White}] BSPWM is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/bspwm
		cp -r bspwm ${LOCALPATH}/.config/bspwm
		chmod +x ${LOCALPATH}/.config/bspwm/bspwmrc
	else
		echo ""
		echo -e "${White} [${Red}-${White}] BSPWM is not installed, installing bspwm"
		sleep 2
		echo ""
		sudo apt update
		echo ""
		sudo apt install bspwm -y
		echo ""
		echo -e "${White} [${Blue}+${White}] BSPWM is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/bspwm
                cp -r bspwm ${LOCALPATH}/.config/bspwm
		chmod +x ${LOCALPATH}/.config/bspwm/bspwmrc
	fi
	if which sxhkd >/dev/null; then
		echo ""
		echo -e "${White} [${Blue}+${White}] SXHKD is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/sxhkd
		cp -r sxhkd ${LOCALPATH}/.config/sxhkd
		chmod +x ${LOCALPATH}/.config/sxhkd/sxhkdrc
	else
		echo ""
		echo -e "${White} [${Red}-${White}] SXHKD is not installed, installing sxhkd"
		sleep 2
		echo ""
		sudo apt update
		echo ""
		sudo apt install sxhkd -y
		echo ""
		echo -e "${White} [${Blue}+${White}] SXHKD is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/sxhkd
                cp -r sxhkd ${LOCALPATH}/.config/sxhkd
                chmod +x ${LOCALPATH}/.config/sxhkd/sxhkdrc
	fi
		echo ""
		echo -e "${White} [${Blue}i${White}] Step 2 installing fonts"
		sleep 2
		echo ""
		echo -e "${White} [${Blue}+${White}] Installing configuration, the fonts"
		sleep 3
		echo ""
		cd ${RUTE}
		sudo rm -rf ${LOCALPATH}/.fonts
		cp -r .fonts ${LOCALPATH}
		sudo cp -r .fonts /usr/share/fonts
		echo -e "${White} [${Blue}+${White}] Installed fonts"
		sleep 2
		echo ""
		echo -e "${White} [${Blue}i${White}] Step 3 check if the kitty terminal is installed"
		sleep 2

	if which kitty >/dev/null; then
		echo ""
		echo -e "${White} [${Blue}+${White}] KITTY is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/kitty
                cp -r kitty ${LOCALPATH}/.config/kitty
	else
		echo ""
		echo -e "${White} [${Red}-${White}] KITTY is not installed, installing kitty"
		sleep 2
		echo ""
		sudo apt update
		echo ""
		sudo apt install kitty -y
		echo ""
		echo -e "${White} [${Blue}+${White}] KITTY is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/kitty
                cp -r kitty ${LOCALPATH}/.config/kitty
		echo ""
		echo -e "${White} [${Blue}i${White}] Step 4 check if the picom compositor is installed"
		sleep 2
	fi
	if which picom >/dev/null; then
		echo ""
		echo -e "${White} [${Blue}+${White}] PICOM is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/picom
                cp -r picom ${LOCALPATH}/.config/picom
	else
		echo ""
		echo -e "${White} [${Red}-${White}] PICOM is not installed, installing picom compositor"
		sleep 2
		echo ""
		sudo apt update
		echo ""
		sudo apt install picom -y
		echo ""
		echo -e "${White} [${Blue}+${White}] PICOM is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
                sudo rm -rf ${LOCALPATH}/.config/picom
                cp -r picom ${LOCALPATH}/.config/picom
		echo ""
		echo -e "${White} [${Blue}i${White}] Step 5 check if the neofetch is installed"
		sleep 2
	fi
	if which neofetch >/dev/null; then
		echo ""
		echo -e "${White} [${Blue}+${White}] NEOFETCH is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/neofetch
                cp -r neofetch ${LOCALPATH}/.config/neofetch
	else
		echo ""
		echo -e "${White} [${Red}-${White}] NEOFETCH is not installed, installing neofetch"
		sleep 2
		echo ""
		sudo apt update
		echo ""
		sudo apt install neofetch -y
		echo ""
		echo -e "${White} [${Blue}+${White}] NEOFETCH is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/neofetch
                cp -r neofetch ${LOCALPATH}/.config/neofetch
                echo ""
                echo -e "${White} [${Blue}i${White}] Step 6 check if the ranger is installed"
                sleep 2
	fi
	if which ranger >/dev/null; then
		echo ""
		echo -e "${White} [${Blue}+${White}] RANGER is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/ranger
                cp -r ranger ${LOCALPATH}/.config/ranger
	else
		echo ""
		echo -e "${White} [${Red}-${White}] RANGER is not installed, installing ranger"
		sleep 2
		echo ""
		sudo apt update
		echo ""
		sudo apt install ranger -y
		echo ""
		echo -e "${White} [${Blue}+${White}] RANGER is installed, installing configuration"
                sleep 2
                cd ${RUTE}/.config
                sudo rm -rf ${LOCALPATH}/.config/ranger
                cp -r ranger ${LOCALPATH}/.config/ranger
		echo ""
		echo -e "${White} [${Blue}i${White}] Step 7 check if the cava is installed"
                sleep 2
	fi
	if which cava >/dev/null; then
		echo ""
		echo -e "${White} [${Blue}+${White}] CAVA is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
		sudo rm -rf ${LOCALPATH}/.config/cava
                cp -r cava ${LOCALPATH}/.config/cava
	else
		echo ""
		echo -e "${White} [${Red}-${White}] CAVA is not installed, installing cava"
		sleep 2
		echo ""
		sudo apt update
		echo ""
		sudo apt install cava -y
		echo ""
		echo -e "${White} [${Blue}+${White}] CAVA is installed, installing configuration"
		sleep 2
                cd ${RUTE}/.config
                sudo rm -rf ${LOCALPATH}/.config/cava
                cp -r cava ${LOCALPATH}/.config/cava
		echo ""
		echo -e "${White} [${Blue}i${White}] Step 8 check if the polybar is installed"
		sleep 2
	fi
	if which polybar >/dev/null; then
		echo ""
		echo -e "${White} [${Blue}+${White}] POLYBAR is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
                sudo rm -rf ${LOCALPATH}/.config/polybar
                cp -r polybar ${LOCALPATH}/.config/polybar
		chmod +x ${LOCALPATH}/.config/polybar/launch.sh
	else
		echo ""
		echo -e "${White} [${Red}-${White}] POLYBAR is not installed, installing polybar"
		sleep 2
		echo ""
		sudo apt update
		echo ""
		sudo apt install polybar -y
		echo ""
		echo -e "${White} [${Blue}+${White}] POLYBAR is installed, installing configuration"
		sleep 2
		cd ${RUTE}/.config
                sudo rm -rf ${LOCALPATH}/.config/polybar
                cp -r polybar ${LOCALPATH}/.config/polybar
		chmod +x ${LOCALPATH}/.config/polybar/launch.sh
	fi
		missing_dependencies
		echo ""
		echo -e "${White} [${Blue}i${White}] Step 10 installing bspwm themes"
		sleep 2
		cd ${RUTE}/.config
		cp -r .themes ${LOCALPATH}
		chmod +x ${LOCALPATH}/.themes/Camila/bspwmrc		#8
		chmod +x ${LOCALPATH}/.themes/Esmeralda/bspwmrc		#7
		chmod +x ${LOCALPATH}/.themes/Nami/bspwmrc		#6
		chmod +x ${LOCALPATH}/.themes/Raven/bspwmrc		#5
		chmod +x ${LOCALPATH}/.themes/Ryan/bspwmrc		#4
		chmod +x ${LOCALPATH}/.themes/Simon/bspwmrc		#3
		chmod +x ${LOCALPATH}/.themes/Xavier/bspwmrc		#2
		chmod +x ${LOCALPATH}/.themes/Zenitsu/bspwmrc		#1
		echo ""
		echo -e "${White} [${Blue}+${White}] Installing theme ${Red}Camila"
		sleep 2
		echo -e "${White} [${Blue}+${White}] Installing theme ${Cyan}Esmeralda"
		sleep 2
		echo -e "${White} [${Blue}+${White}] Installing theme ${Black}Nami"
		sleep 2
		echo -e "${White} [${Blue}+${White}] Installing theme ${Purple}Raven"
		sleep 2
		echo -e "${White} [${Blue}+${White}] Installing theme ${Green}Ryan"
		sleep 2
		echo -e "${White} [${Blue}+${White}] Installing theme ${Blue}Simon"
		sleep 2
		echo -e "${White} [${Blue}+${White}] Installing theme ${IWhite}Xavier"
		sleep 2
		echo -e "${White} [${Blue}+${White}] Installing theme ${Yellow}Zenitsu"
		sleep 2
fi
}


# CALLS THE SCRIPT
reset
setup

