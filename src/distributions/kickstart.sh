#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../core/logging.sh"
source "${BASH_SOURCE%/*}/../core/config.sh"

install_kickstart() {
    local profile_dir="$1"
    
    if [ -z "$profile_dir" ]; then
        log_error "Profile directory not specified"
        return 1
    fi

    log_info "Installing kickstart.nvim..."
    
    if [ -d "$profile_dir" ]; then
        log_warning "Directory already exists: $profile_dir"
        read -p "Do you want to overwrite it? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
        rm -rf "$profile_dir"
    fi

    if git clone "${DISTRIBUTION_URLS["kickstart"]}" "$profile_dir"; then
        rm -rf "$profile_dir/.git"
        log_success "kickstart.nvim installed successfully!"
        
        # Display post-installation instructions
        echo
        log_info "kickstart.nvim Post-Installation Steps:"
        echo "1. Start Neovim to initialize plugins"
        echo "2. Customize your configuration by editing ~/.config/$profile_dir/init.lua"
        echo "3. See https://github.com/nvim-lua/kickstart.nvim for more information"
        
        return 0
    else
        log_error "Failed to install kickstart.nvim"
        return 1
    fi
}
