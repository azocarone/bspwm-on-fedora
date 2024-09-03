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
    [check]=$(format_bullet "green" "✓")
    [error]=$(format_bullet "red" "✗")
    [info]=$(format_bullet "blue" "i")
    [question]=$(format_bullet "red" "?")
    [success]=$(format_bullet "yellow" "!")
)

local -A files=(
    [banner]="./resources/banner.txt"
    [pkgs_rpm]="./configs/pkgs_rpm.yaml"
    [pkgs_github]="./configs/pkgs_github.yaml"
)

local -A packages=(
    [rpm]=$(get_rpm_package "${files[pkgs_rpm]}")
    [github]=$(get_github_package "${files[pkgs_github]}")
)

# :- Ternary operator: sets USERNAME to SUDO_USER if defined, otherwise uses USER.
# SUDO_USER and USER are environment variables of the Linux operating system.
local USERNAME="${SUDO_USER:-$USER}" 

local -A paths=(
    [home]=$"/home/${USERNAME}"
    [current]="$(pwd)"
)

local -A rpm_pkgs_permissions=(
    [bspwm]=1
    [sxhkd]=1
    [kitty]=0
    [picom]=0
    [neofetch]=0
    [ranger]=0
    [cava]=0
    [polybar]=1
)

local -A font_paths=(
    [source]="${paths[current]}/.fonts"
    [user]="${paths[home]}/.fonts"
    [system]="/usr/local/share/fonts"
)

local bspwm_assets=("${paths[current]}/scripts" "${paths[current]}/.themes")

local zsh_assets=("${paths[current]}/.zshrc" "${paths[current]}/.p10k.zsh")
