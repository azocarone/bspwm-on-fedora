#!/bin/bash

get_rpm_packages() {
    local yaml_file="$1"
    local rpm_packages=$(awk '
        /^[^:]+:$/ { in_list=1; next }
        /^\s*$/ { in_list=0 }
        /^\s*-\s+/ && in_list { print $2 }
    ' "$yaml_file")
    
    echo "$rpm_packages"
}

get_git_packages(){
    local yaml_file="$1"
    local git_packages=$(awk '
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
    
    echo "$git_packages"
}

format_bullet() {
    local color_symbol=$1
    local symbol=$2
    echo -e "\n${colors[white]} [${colors[$color_symbol]}$symbol${colors[white]}]"
}

local -A files=(
    [banner]="resources/banner.txt"
    [rpm_yaml]="rpm_packages.yaml"
    [git_yaml]="git_packages.yaml"
)

local -A packages=(
    [rpm]=$(get_rpm_packages "${files[rpm_yaml]}")
    [git]=$(get_git_packages "${files[git_yaml]}")
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
    [surprise]=$(format_bullet "yellow" "!")
    [check]=$(format_bullet "green" "✓")
    [error]=$(format_bullet "red" "✗")
)

local -A paths=(
    [home]=$"/home/${USERNAME}"
    [current]=$(pwd)
    [install]="/usr/local/bin/"
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
