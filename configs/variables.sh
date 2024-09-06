declare -A colors=(
    [red]='\033[1;31m'
    [green]='\033[1;32m'
    [yellow]='\033[33m'
    [blue]='\033[1;34m'
    [purple]='\033[1;35m'
    [cyan]='\033[1;36m'
    [white]='\033[1;37m'
)

declare -A bullets=(
    [check]=$(format_bullet "green" "✓")
    [error]=$(format_bullet "red" "✗")
    [info]=$(format_bullet "blue" "i")
    [question]=$(format_bullet "red" "?")
    [success]=$(format_bullet "yellow" "!")
)

declare -A files=(
    [banner]="./resources/banner.txt"
    [pkgs_rpm]="./configs/pkgs_rpm.yaml"
    [pkgs_github]="./configs/pkgs_github.yaml"
)

declare -A packages=(
    [rpm]=$(get_rpm_package "${files[pkgs_rpm]}")
    [github]=$(get_github_package "${files[pkgs_github]}")
)

# :- Ternary operator: sets USERNAME to SUDO_USER if defined, otherwise uses USER.
# SUDO_USER and USER are environment variables of the Linux operating system.
USERNAME="${SUDO_USER:-$USER}" 

declare -A paths=(
    [home]=$"/home/${USERNAME}"
    [current]="$(pwd)"
)

declare -A rpm_pkgs_permissions=(
    [bspwm]=1
    [sxhkd]=1
    [kitty]=0
    [picom]=0
    [neofetch]=0
    [ranger]=0
    [cava]=0
    [polybar]=1
)

declare -A font_paths=(
    [source]="${paths[current]}/.fonts"
    [user]="${paths[home]}/.fonts"
    [system]="/usr/local/share/fonts"
)

bspwm_assets=("${paths[current]}/scripts" "${paths[current]}/.themes")

zsh_assets=("${paths[current]}/.zshrc" "${paths[current]}/.p10k.zsh")
