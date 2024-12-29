#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source core scripts
source "$SCRIPT_DIR/../core/logging.sh"
source "$SCRIPT_DIR/../core/config.sh"

install_astronvim() {
    local config_dir="$1"
    
    if [ -z "$config_dir" ]; then
        log_error "Configuration directory not specified"
        return 1
    fi 

    log_info "Installing AstroNvim distribution..."
    
    if [ -d "$config_dir" ]; then
        log_warning "Directory already exists: $config_dir"
        read -p "Do you want to overwrite it? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
        rm -rf "$config_dir"
    fi

    # Clone AstroNvim template
    if ! git clone --depth 1 https://github.com/AstroNvim/template "$config_dir"; then
        log_error "Failed to clone AstroNvim template repository"
        return 1
    fi

    # Remove .git directory
    rm -rf "$config_dir/.git"
    
    log_success "AstroNvim installed successfully!"
    log_info "You can now run 'nvim' with your new AstroNvim configuration"
    return 0
}
