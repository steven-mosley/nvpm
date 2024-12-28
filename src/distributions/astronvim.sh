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

    mkdir -p "$config_dir"
    echo 'print("Welcome to your AstroNvim profile!")' > "$config_dir/init.lua"
    
    log_success "AstroNvim installed successfully!"
    log_info "You can now run 'nvim' with your new AstroNvim configuration"
    return 0
}
