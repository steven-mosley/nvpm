#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../core/logging.sh"
source "${BASH_SOURCE%/*}/../core/config.sh"

install_astronvim() {
    local profile_dir="$1"
    
    if [ -z "$profile_dir" ]; then
        log_error "Profile directory not specified"
        return 1
    fi 

    log_info "Installing AstroNvim distribution..."
    
    if [ -d "$profile_dir" ]; then
        log_warning "Directory already exists: $profile_dir"
        read -p "Do you want to overwrite it? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
        rm -rf "$profile_dir"
    fi

    if git clone --depth 1 "${DISTRIBUTION_URLS["astronvim"]}" "$profile_dir"; then
        rm -rf "$profile_dir/.git"
        log_success "AstroNvim installed successfully!"
        log_info "You can now run 'nvim' with your new AstroNvim configuration"
        return 0
    else
        log_error "Failed to install AstroNvim"
        return 1
    fi
}
