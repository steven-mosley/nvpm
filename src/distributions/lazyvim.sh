#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../core/logging.sh"
source "${BASH_SOURCE%/*}/../core/config.sh"

install_lazyvim() {
    local profile_dir="$1"
    
    if [ -z "$profile_dir" ]; then
        log_error "Profile directory not specified"
        return 1
    fi

    log_info "Installing LazyVim distribution..."
    
    if [ -d "$profile_dir" ]; then
        log_warning "Directory already exists: $profile_dir"
        read -p "Do you want to overwrite it? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
        rm -rf "$profile_dir"
    fi

    if git clone "${DISTRIBUTION_URLS["lazyvim"]}" "$profile_dir"; then
        rm -rf "$profile_dir/.git"
        log_success "LazyVim installed successfully!"
        
        # Display post-installation instructions
        echo
        log_info "LazyVim Post-Installation Steps:"
        echo "1. Start Neovim to initialize LazyVim"
        echo "2. Wait for plugins to be installed"
        echo "3. Customize your configuration in ~/.config/$profile_dir/lua/config/"
        
        return 0
    else
        log_error "Failed to install LazyVim"
        return 1
    fi
}
