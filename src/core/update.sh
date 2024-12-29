#!/usr/bin/env bash

set -e

# Load configuration and logging functions
source "${BASH_SOURCE%/*}/config.sh"
source "${BASH_SOURCE%/*}/logging.sh"

# Function to fetch the latest scripts from GitHub
fetch_latest_scripts() {
    log_info "Fetching the latest scripts from GitHub..."

    # Clone the repository to a temporary directory to fetch the latest version
    local tmp_dir
    tmp_dir=$(mktemp -d)
    git clone "$NVPM_REPO" "$tmp_dir" >/dev/null 2>&1

    # Copy the latest scripts to the NVPM root directory
    cp -r "$tmp_dir/"* "$NVPM_ROOT/"
    rm -rf "$tmp_dir"

    log_success "Fetched the latest scripts from GitHub"
}

# Function to fetch the latest version information from GitHub
fetch_latest_version_info() {
    # Clone the repository to a temporary directory to fetch the latest version file
    local tmp_dir
    tmp_dir=$(mktemp -d)
    git clone --depth=1 "$NVPM_REPO" "$tmp_dir" >/dev/null 2>&1 || {
        log_error "Failed to fetch the latest version information."
        rm -rf "$tmp_dir"
        return 1
    }
    
    if [ -f "$tmp_dir/version" ]; then
        cat "$tmp_dir/version"
    else
        log_error "Version file not found in the repository."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"
}

# Function to update NVPM
update_nvpm() {
    fetch_latest_scripts

    # Update the local version file
    local remote_version
    remote_version=$(fetch_latest_version_info) || return 1
    echo "$remote_version" > "$VERSION_FILE"

    log_success "NVPM updated to the latest version."
}

# Main entry point
main() {
    update_nvpm
}

# Run the main function
main
