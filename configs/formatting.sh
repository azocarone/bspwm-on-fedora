format_bullet() {
    local color_symbol=$1
    local symbol=$2
    
    echo -e "\n${colors[white]} [${colors[$color_symbol]}$symbol${colors[white]}]"
}
