#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../core/logging.sh"
source "${BASH_SOURCE%/*}/../core/config.sh"

install_lunarvim() {
    local profile_name="$1"
    
    if [ -z "$profile_name" ]; then
        log_error "Profile name not specified"
        return 1
    fi

    log_info "Installing LunarVim..."
    
    # Since LunarVim has its own installer and configuration location,
    # we need to handle it differently
    
    # Create a temporary directory for the installer
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || exit 1
    
    # Download and run the LunarVim installer
    if curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh -o install.sh; then
        log_info "Running LunarVim installer..."
        bash install.sh
        install_status=$?
        
        # Cleanup
        cd - > /dev/null
        rm -rf "$temp_dir"
        
        if [ $install_status -eq 0 ]; then
            log_success "LunarVim installed successfully!"
            
            # Create profile wrapper
            create_lunarvim_wrapper "$profile_name"
            
            # Display post-installation instructions
            echo
            log_info "LunarVim Post-Installation Steps:"
            echo "1. Configuration files are located in ~/.config/lvim/"
            echo "2. Run 'lvim' to start LunarVim"
            echo "3. See https://www.lunarvim.org/docs/configuration for customization"
            
            return 0
        else
            log_error "Failed to install LunarVim"
            return 1
        fi
    else
        log_error "Failed to download LunarVim installer"
        return 1
    fi
}

create_lunarvim_wrapper() {
    local profile_name="$1"
    local wrapper_path="$NVPM_SHIMS/nvim-$profile_name"
    
    # Create wrapper script
    cat > "$wrapper_path" << 'EOF'
#!/usr/bin/env bash
exec lvim "$@"
EOF
    
    chmod +x "$wrapper_path"
    log_success "Created LunarVim wrapper: nvim-$profile_name"
}
