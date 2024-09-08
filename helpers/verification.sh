#!/bin/bash
# =============================================================================
#  Helper functions for verifications
# =============================================================================

check_file_exists() {
    local file="$1"
    [[ -f "$file" ]] || {
        echo_error "File $file not found."
        return 1
    }
}
