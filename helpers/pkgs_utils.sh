#!/bin/bash
# =============================================================================
#  Helper functions for manage package fetching and parsing from YAML.
# =============================================================================

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
