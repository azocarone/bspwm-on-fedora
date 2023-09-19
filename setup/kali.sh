#!/bin/bash

# CHANGE DICTORY .CONFIG
cd ${RUTE} ; cd .. ; cd .config

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
echo -e "${White} ╔───────────────────────────────────────────────╗                					"
echo -e "${White} |${Cyan} ██████╗ ███████╗██████╗ ██╗    ██╗███╗   ███╗${White} |${Red} []${White} INFORMATION	"
echo -e "${White} |${Cyan} ██╔══██╗██╔════╝██╔══██╗██║    ██║████╗ ████║${White} |${Red} []${White} ${USERNAME}	"
echo -e "${White} |${Cyan} ██████╔╝███████╗██████╔╝██║ █╗ ██║██╔████╔██║${White} |${Red} []${White} ${KERNEL}		"
echo -e "${White} |${Cyan} ██╔══██╗╚════██║██╔═══╝ ██║███╗██║██║╚██╔╝██║${White} |${Red} []${White} ${DISTRIBUTION}	"
echo -e "${White} |${Cyan} ██████╔╝███████║██║     ╚███╔███╔╝██║ ╚═╝ ██║${White} |${Red} []${White} ${HOST}		"
echo -e "${White} |${Cyan} ╚═════╝ ╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝     ╚═╝${White} |${Red} [󰊠]${White} ${BIT}		"
echo -e "${White} ┖───────────────────────────────────────────────┙							"
echo -e "${White} [${Blue}i${White}] Hello ${Red}${USERNAME}${White}, This is the bspwm installation script for kali linux"
}

# INSTALL BSPWM KALI LINUX SETUP
setup () {
clear
banner
sleep 1
echo -ne "${White} [${Blue}!${White}] Do you want to continue with the installation? Y|N ▶ ${Red}"
read quest
if [ $quest = Y ]; then
	echo ""
	echo -e "${White} [${Blue}i${White}] Step 1 checking if bspwm and sxhkd are installed"
	if which bspwm >/dev/null; then
		echo ""
		echo -e "${White} [${Blue}+${White}] BSPWM is installed, installing configuration"
		sudo rm -rf ${LOCALPATH}/.config/bspwm
		cp bspwm ${LOCALPATH}/.config/bspwm
		chmod +x ${LOCALPATH}/.config/bspwm/bspwmrc
	else
		echo ""
		echo -e "${White} [${Red}-${White}] BSPWM is not installed, installing bspwm"
		sudo apt update>/dev/null
		sudo apt install bspwm -y>/dev/null
		echo -e "${White} [${Blue}+${White}] BSPWM is installed, installing configuration"
		sudo rm -rf ${LOCALPATH}/.config/bspwm
                cp bspwm ${LOCALPATH}/.config/bspwm
		chmod +x ${LOCALPATH}/.config/bspwm/bspwmrc
	fi
fi
}


# CALLS THE SCRIPT
reset
setup
