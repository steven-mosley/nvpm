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

    # Prompt for kickstart version
    echo
    log_info "Please choose kickstart.nvim version:"
    echo "1) Standard (single init.lua)"
    echo "2) Modular (split configuration)"
    read -p "Enter your choice (1 or 2): " version_choice
    echo

    case "$version_choice" in
        1)
            log_info "Installing standard kickstart.nvim..."
            if git clone "${DISTRIBUTION_URLS["kickstart"]}" "$profile_dir"; then
                rm -rf "$profile_dir/.git"
                log_success "Standard kickstart.nvim installed successfully!"
            else
                log_error "Failed to install standard kickstart.nvim"
                return 1
            fi
            ;;
        2)
            log_info "Installing modular kickstart.nvim..."
            if git clone "${DISTRIBUTION_URLS["kickstart-modular"]}" "$profile_dir"; then
                rm -rf "$profile_dir/.git"
                log_success "Modular kickstart.nvim installed successfully!"
            else
                log_error "Failed to install modular kickstart.nvim"
                return 1
            fi
            ;;
        *)
            log_error "Invalid choice. Please select 1 or 2"
            return 1
            ;;
    esac
        
    # Display post-installation instructions based on version
    echo
    log_info "kickstart.nvim Post-Installation Steps:"
    if [ "$version_choice" == "1" ]; then
        echo "1. Start Neovim to initialize plugins"
        echo "2. Customize your configuration by editing ~/.config/$profile_dir/init.lua"
    else
        echo "1. Start Neovim to initialize plugins"
        echo "2. Customize your configuration in ~/.config/$profile_dir/lua/custom/"
        echo "3. Main configurations are split into modules in ~/.config/$profile_dir/lua/kickstart/"
    fi
    echo "4. See https://github.com/nvim-lua/kickstart.nvim for more information"
    
    return 0
}
