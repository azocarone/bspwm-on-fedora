#!/usr/bin/env bash

# DIR ROFI
SDIR="$HOME/.config/polybar/cuts/scripts"

# THE THEMES DIR
THEMESDIR="/home/alvinpix/.themes"

# DIR THEMES
GHOST="/home/alvinpix/.themes/Ghost"
ITACHI="/home/alvinpix/.themes/Itachi"

# LAUNCH ROFI
MENU="$(rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p '' \
-theme $SDIR/rofi/styles.rasi \
<<< " Itachi|")"
            case "$MENU" in
                                *Itachi) "$GHOST"/styles.sh --mode1 ;;
            esac
