#!/bin/bash

local -A files

files[banner]="resources/banner.txt"
files[rpm_yaml]="rpm_packages.yaml"
files[git_yaml]="git_packages.yaml"

local -A packages

packages[rpm]=$(get_rpm_packages "${files[rpm_yaml]}")
packages[git]=$(get_git_packages "${files[git_yaml]}")

local -A colors

colors[white]='\033[1;37m'
colors[red]='\033[1;31m'
colors[green]='\033[1;32m'
colors[cyan]='\033[1;36m'
colors[blue]='\033[1;34m'
colors[yellow]='\033[33m'

local -A bullets

bullets[info]="\n${colors[white]} [${colors[blue]}i${colors[white]}]"
bullets[question]="\n${colors[white]} [${colors[red]}?${colors[white]}]"
bullets[surprise]="\n${colors[white]} [${colors[yellow]}¡${colors[white]}]"
bullets[check]="\n${colors[white]} [${colors[green]}✓${colors[white]}]"

local -A paths

paths[home]=$"/home/${USERNAME}"
paths[current]=$(pwd)
paths[install]="/usr/local/bin/"
