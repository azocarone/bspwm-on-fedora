#!/bin/bash
# =============================================================================
#  Helper functions for GitHub package installation.
# =============================================================================

handle_git_repository() {
    local repo_url="$1"
    local target_dir="$2"
    local build_command="$3"
    local target_bin="$4"
    
    local base_path=$(comm_expand_path "$target_dir")
    
    local repo_path

    if ! repo_path=$(clone_repository "$repo_url" "$base_path"); then
        return 1 # Error already handled in clone_repository.
    fi
    
    if ! build_from_source "$repo_path" "$build_command"; then
        return 1 # Error already handled in build_from_source.
    fi

    if ! deploy_executable "$repo_path" "$target_bin"; then
        return 1  # Error already handled in deploy_executable.
    fi

    echo "$repo_path"
}

clone_repository() {
    local repo_url="$1"
    local base_path="$2"
    
    local repo_path=$(determine_clone_path "$repo_url" "$base_path")
    
    if comm_directory_or_file_exists "$repo_path"; then
        return 1
    fi
    
    if ! git clone --depth=1 "$repo_url" "$repo_path"; then
        echo_error "Cloning the ${repo_url} repository failed."
        return 1
    fi

    echo "${repo_path}"
}

determine_clone_path() {
    local repo_url="$1"
    local base_path="${2:-${paths[current]}}"
    
    local repo_name=$(basename "${repo_url}" .git)
    local repo_path # Type absolute path
    
    if [[ "${base_path}" == *"/." ]]; then
        # Case 1: if base_path ends in “/.”, do not add “/”.
        repo_path="${base_path}${repo_name}"
    else
        # Case 2: in any other case, add “/”.
        repo_path="${base_path}/${repo_name}"
    fi

    echo "${repo_path}"
}

build_from_source() {
    local repo_path="$1"
    local build_command="$2"

    if [[ -z $build_command ]]; then
        echo_success "No building is required."
        return 0
    fi

    local build_log=$(mktemp)
    trap 'rm -f "$build_log"' EXIT 

    if ! (
        cd "$repo_path" &&
        bash -c "$build_command" 2>&1 | tee -a "$build_log" >&2
    ); then
        echo_error "Building the package in ${repo_path} failed."
        return 1
    fi
}

deploy_executable() {
    local repo_path="$1"
    local target_bin="$2"

    if [[ -z ${target_bin} ]]; then
        echo_success "No executable deployment needed."
        return 0
    fi

    local deploy_log=$(mktemp)
    trap 'rm -f "$deploy_log"' EXIT 

    local repo_name=$(basename "$repo_path")
    local bin_file="$repo_path/$repo_name"

    if has_install_script "$repo_path"; then
        echo_success "Installation script found; skipping executable deployment."
        return 0
    fi

    if [[ -f $bin_file ]]; then
        comm_copy_files_to_destination "$bin_file" "$target_bin" 2>&1 | tee -a "$deploy_log" >&2
    else
        echo_error "Binary file ${bin_file} does not exist."
        return 1
    fi
}

has_install_script() {
    local repo_path="$1"

    local pattern="install*"

    if find "$repo_path" -maxdepth 1 -name "$pattern" -type f | grep -q .; then
        return 0
    else
        return 1
    fi
}

# ----> ^^^ <----

handle_download_artifact() {
    local repo_url="$1"
    local target_dir="$2"

    local base_path

    base_path=$(comm_expand_path "$target_dir")
    download_artifact "${repo_url}" "${base_path}"
}

download_artifact(){
    local repo_url="$1"
    local base_path="$2"

    local file=$(basename "$repo_url")

    if [[ -f "$base_path/$file" ]]; then
        echo_success "The file ${file} already exists."
        return 1
    fi
        
    if sudo mkdir -p "$base_path" && sudo curl -L "$repo_url" -o "$base_path/$file"; then
        echo_check "The file ${file} downloaded successfully."
    else
        echo_error "Failed to download the file ${file}."
        return 1
    fi
} 

# ----> ^^^ <----

handle_remove() {
    local remove_repo="$1"
    local repo_path="$2"
    
    if [[ "$remove_repo" -eq 1 && -n "$repo_path" ]]; then
        comm_remove_items "$repo_path" || return 1
    fi

    return 0
}
