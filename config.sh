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
        BEGIN { OFS="," }

        /^\s*url:/ {
            match($0, /url:\s*"([^"]*)"/, arr)
            url = arr[1]
        }

        /^\s*target:/ {
            match($0, /target:\s*"([^"]*)"/, arr)
            target = arr[1]
        }

        /^\s*command:/ {
            match($0, /command:\s*"([^"]*)"/, arr)
            command = arr[1]
        }

        /^\s*binary:/ {
            match($0, /binary:\s*"([^"]*)"/, arr)
            binary = arr[1]
        }

        /^\s*cleanup:/ {
            match($0, /cleanup:\s*([0-9]+)/, arr)
            cleanup = arr[1]
            print url, target, command, binary, cleanup
        }
    ' "$yaml")
    
    echo "$pkgs_github"
}

format_bullet() {
    local color_symbol=$1
    local symbol=$2
    
    echo -e "\n${colors[white]} [${colors[$color_symbol]}$symbol${colors[white]}]"
}

# :- Ternary operator: sets USERNAME to SUDO_USER if defined, otherwise uses USER.
# SUDO_USER and USER are environment variables of the Linux operating system.
local USERNAME="${SUDO_USER:-$USER}" 

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
    [rpm]=$(get_pkgs_rpm "${files[pkgs_rpm]}")
    [github]=$(get_pkgs_github "${files[pkgs_github]}")
)

local -A paths=(
    [home]=$"/home/${USERNAME}"
    [current]="$(pwd)"
)

local -A privileges=(
    [bspwm]=1
    [sxhkd]=1
    [kitty]=0
    [picom]=0
    [neofetch]=0
    [ranger]=0
    [cava]=0
    [polybar]=1
)

local -A directories=(
    [source]="${paths[current]}/.fonts"
    [user]="${paths[home]}/.fonts"
    [system]="/usr/local/share/fonts"
)

local bspwm_assets=("scripts" ".themes")

local zsh_assets=(".zshrc" ".p10k.zsh")
