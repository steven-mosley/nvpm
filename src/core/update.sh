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

# Function to update NVPM
update_nvpm() {
    fetch_latest_scripts

    # Update the local version file
    local remote_version
    remote_version=$(fetch_latest_version_info)
    echo "$remote_version" > "$VERSION_FILE"

    log_success "NVPM updated to the latest version."
}

# Main entry point
main() {
    update_nvpm
}

# Run the main function
main
