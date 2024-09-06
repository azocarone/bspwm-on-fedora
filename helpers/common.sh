# =============================================================================
#  Project Name: bspwm-on-fedora
#  Description : Scripts to install and configure a professional 
#                BSPWM environment on Fedora Linux Workstation. 
# -----------------------------------------------------------------------------
#  Author      : José AZOCAR (azocarone)
#  Created on  : 2024-09-06
#  Version     : RC3
# -----------------------------------------------------------------------------
#  Usage       : Common funcs. and their related aux. funcs.
# =============================================================================

comm_expand_path() {
    local target_dir="$1"
    
    local resolved_path

    case "$target_dir" in
        ".") 
            resolved_path="${paths[current]}"
            ;;
        "~")
            resolved_path="${paths[home]}"
            ;;
        "~/"*)
            # Remove the “~/” and add the path to home
            resolved_path="${paths[home]}/${target_dir:2}"
            ;;
        /*)
            # Any absolute path is returned as is
            resolved_path="$target_dir"
            ;;
        *)
            echo_error "The target directory ${target_dir} is not recognized."
            return 1
            ;;
    esac

    echo "$resolved_path"
}

comm_make_executable() {
    local assets=("$@")

    local asset

    echo_info "Sets execution permission:"

    for asset in "${assets[@]}"; do
        if ! comm_directory_or_file_exists "$asset"; then
            return 1
        fi

        if [[ -d "$asset" ]]; then
            find "$asset" -type f -exec grep -Il '^#!' {} \; -exec chmod +x {} \;
        else
            grep -Il '^#!' "$asset" && chmod +x "$asset"
        fi
    done
}

comm_directory_or_file_exists() {
    local path="$1"

    if [[ -e "$path" ]]; then
        echo_info "The path ${path} exists."
        return 0
    else
        echo_error "The specified path ${path} does not exist."
        return 1
    fi
}

comm_copy_files_to_destination() {
    local -a assets=("${@:1:$#-1}") # All parameters except the last one
    local target="${!#}" # The last parameter

    local copy_cmd asset

    echo_info "Copy assets from directories or files:"

    copy_cmd=$(determine_copy_command "$target")

    for asset in "${assets[@]}"; do
        process_asset "$asset" "$target" "$copy_cmd" || return 1
    done
}

determine_copy_command() {
    local target="$1"
    local temp_file="$2"
    
    [[ -e "$target" && ! -w "$target" ]] && echo "sudo cp" || echo "cp"
}

process_asset() {
    local asset="$1"
    local target="$2"
    local copy_cmd="$3"
    local temp_file="$4"

    if ! comm_directory_or_file_exists "$asset"; then
        return 1
    fi

    if [[ -d "$asset" ]]; then
        $copy_cmd -rv "$asset" "$target"
    else
        $copy_cmd -v "$asset" "$target"
    fi
}

comm_remove_items() {
    local items=("$@")

    local item
    local success=true

    if [[ ${#items[@]} -eq 0 ]]; then
        echo_error "No directories or files were provided for deletion."
        return 1
    fi

    for item in "${items[@]}"; do
        if [[ -d "$item" ]]; then
            delete_directory "$item" || success=false
        elif [[ -f "$item" ]]; then
            delete_file "$item" || success=false
        else
            echo_error "${item} is not a directory or file."
            success=false
        fi
    done

    [[ "$success" = true ]] && return 0 || return 1
}

delete_directory() {
    local dir="$1"

    rm -rf "$dir"
    
    if [[ $? -ne 0 ]]; then
        echo_error "The directory ${dir} could not be removed."
        return 1
    else
        echo_check "The directory ${dir} has been successfully removed."
        return 0
    fi
}

delete_file() {
    local file="$1"

    rm -f "$file"
    
    if [[ $? -ne 0 ]]; then
        echo_error "The file ${file} could not be deleted."
        return 1
    else
        echo_check "The file ${file} has been successfully deleted."
        return 0
    fi
}

