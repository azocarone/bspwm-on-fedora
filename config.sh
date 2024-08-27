format_bullet() {
    local color_symbol=$1
    local symbol=$2
    
    echo -e "\n${colors[white]} [${colors[$color_symbol]}$symbol${colors[white]}]"
}

get_rpm_package() {
    local yaml="$1"
    
    local pkgs_rpm=$(awk '
        /^[^:]+:$/ { in_list=1; next }
        
        /^\s*$/ { in_list=0 }
        
        /^\s*-\s+/ && in_list { print $2 }
    ' "$yaml")
    
    echo "$pkgs_rpm"
}

get_github_package(){
    local yaml="$1"
    
    local pkgs_github=$(awk '
        BEGIN { OFS="," }

        /^\s*repo_url:/ {
            match($0, /repo_url:\s*"([^"]*)"/, arr)
            repo_url = arr[1]
        }

        /^\s*target_dir:/ {
            match($0, /target_dir:\s*"([^"]*)"/, arr)
            target_dir = arr[1]
        }

        /^\s*build_command:/ {
            match($0, /build_command:\s*"([^"]*)"/, arr)
            build_command = arr[1]
        }

        /^\s*target_bin:/ {
            match($0, /target_bin:\s*"([^"]*)"/, arr)
            target_bin = arr[1]
        }

        /^\s*remove_repo:/ {
            match($0, /remove_repo:\s*([0-9]+)/, arr)
            remove_repo = arr[1]
            print repo_url, target_dir, build_command, target_bin, remove_repo
        }
    ' "$yaml")
    
    echo "$pkgs_github"
}

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

local -A files=(
    [banner]="resources/banner.txt"
    [pkgs_rpm]="pkgs_rpm.yaml"
    [pkgs_github]="pkgs_github.yaml"
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

local -A perms_pkgs=(
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
