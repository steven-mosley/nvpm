#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../core/logging.sh"
source "${BASH_SOURCE%/*}/../core/config.sh"

install_nvchad() {
    local profile_dir="$1"
    
    if [ -z "$profile_dir" ]; then
        log_error "Profile directory not specified"
        return 1
    fi 

    log_info "Installing NvChad distribution..."
    
    if [ -d "$profile_dir" ]; then
        log_warning "Directory already exists: $profile_dir"
        read -p "Do you want to overwrite it? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
        rm -rf "$profile_dir"
    fi

    if git clone "${DISTRIBUTION_URLS["nvchad"]}" "$profile_dir"; then
        rm -rf "$profile_dir/.git"
        log_success "NvChad installed successfully!"
        
        # Display post-installation instructions
        echo
        log_info "Important NvChad Post-Installation Steps:"
        echo "1. Run :MasonInstallAll command after lazy.nvim finishes downloading plugins"
        echo "2. To customize NvChad, edit the files in ~/.config/$profile_dir/lua/custom/"
        echo "3. See :help nvchad for more information"
        
        return 0
    else
        log_error "Failed to install NvChad"
        return 1
    fi
}
