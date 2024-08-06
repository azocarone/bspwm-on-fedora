#!/bin/bash

get_pkgs_rpm() {
    local yaml="$1"
    local pkgs_rpm=$(awk '
        /^[^:]+:$/ { in_list=1; next }
        /^\s*$/ { in_list=0 }
        /^\s*-\s+/ && in_list { print $2 }
    ' "$yaml")
    
    echo "$pkgs_rpm"
}

get_pkgs_github(){
    local yaml="$1"
    local pkgs_github=$(awk '
        /^\s*git_url:/ {
            git_url=gensub(/.*git_url: /, "", 1)
            gsub(/"/, "", git_url)
        }
        /^\s*build_command:/ {
            build_command=gensub(/.*build_command: /, "", 1)
            gsub(/"/, "", build_command)
            print git_url, build_command
        }
    ' "$yaml")
    
    echo "$pkgs_github"
}

format_bullet() {
    local color_symbol=$1
    local symbol=$2
    
    echo -e "\n${colors[white]} [${colors[$color_symbol]}$symbol${colors[white]}]"
}

local -A files=(
    [banner]="resources/banner.txt"
    [pkgs_rpm]="pkgs_rpm.yaml"
    [pkgs_github]="pkgs_github.yaml"
)

local -A colors=(
    [red]='\033[1;31m'
    [green]='\033[1;32m'
    [yellow]='\033[33m'
    [blue]='\033[1;34m'
    [purple]='\033[1;35m'
    [cyan]='\033[1;36m'
    [white]='\033[1;37m'
)

local -A bullets=(
    [info]=$(format_bullet "blue" "i")
    [question]=$(format_bullet "red" "?")
    [success]=$(format_bullet "yellow" "!")
    [check]=$(format_bullet "green" "✓")
    [error]=$(format_bullet "red" "✗")
)

local -A packages=(
    [rpm]=$(get_pkgs_rpm "${files[pkgs_rpm]}")
    [github]=$(get_pkgs_github "${files[pkgs_github]}")
)

local -A paths=(
    [home]=$"/home/${USERNAME}/"
    [current]="$(pwd)/"
    [bin]="/usr/local/bin/"
)

local -A packages_permission=(
    [bspwm]=1
    [sxhkd]=1
    [kitty]=0
    [picom]=0
    [neofetch]=0
    [ranger]=0
    [cava]=0
    [polybar]=1
)

local -A paths_fonts=(
    [source]=".fonts"
    [user]="${paths[home]}/.fonts"
    [system]="/usr/local/share/fonts"
)

local assets=("scripts" ".themes")
