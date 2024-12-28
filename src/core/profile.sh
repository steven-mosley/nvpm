#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/logging.sh"
source "${BASH_SOURCE%/*}/config.sh"
source "${BASH_SOURCE%/*}/../ui/menu.sh"

# Source all distribution installers
for installer in "${BASH_SOURCE%/*}"/../distributions/*.sh; do
    source "$installer"
done

create_profile() {
    local profile_name="$1"
    
    if [ -z "$profile_name" ]; then
        log_error "Profile name is required"
        return 1
    fi

    # Validate profile name
    if [[ ! "$profile_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Invalid profile name. Use only letters, numbers, underscore and hyphen"
        return 1
    fi

    log_info "Creating new profile: $profile_name"

    # Select distribution type
    local dist_type
    dist_type=$(select_distribution)
    
    if [ -z "$dist_type" ]; then
        return 1
    fi

    local profile_dir="$CONFIG_DIR/$profile_name"

    case "$dist_type" in
        "vanilla")
            create_vanilla_profile "$profile_dir"
            ;;
        "astronvim")
            install_astronvim "$profile_dir"
            ;;
        "nvchad")
            install_nvchad "$profile_dir"
            ;;
        "lazyvim")
            install_lazyvim "$profile_dir"
            ;;
        "kickstart")
            install_kickstart "$profile_dir"
            ;;
        "lunarvim")
            install_lunarvim "$profile_name"
            ;;
        *)
            log_error "Unknown distribution type: $dist_type"
            return 1
            ;;
    esac

    # Create profile wrapper if not LunarVim (which creates its own wrapper)
    if [ "$dist_type" != "lunarvim" ]; then
        create_profile_wrapper "$profile_name"
    fi

    log_success "Profile '$profile_name' created successfully!"
}

create_vanilla_profile() {
    local profile_dir="$1"

    mkdir -p "$profile_dir"
    
    # Create minimal init.lua
    cat > "$profile_dir/init.lua" << 'EOF'
-- Vanilla Neovim Configuration
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.termguicolors = true

-- Basic key mappings
vim.g.mapleader = ' '
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })

-- Add your custom configuration below
EOF

    log_success "Created vanilla Neovim configuration"
}

create_profile_wrapper() {
    local profile_name="$1"
    local wrapper_path="$NVPM_SHIMS/nvim-$profile_name"

    # Create wrapper script
    cat > "$wrapper_path" << EOF
#!/usr/bin/env bash
exec env NVIM_APPNAME="$profile_name" nvim "\$@"
EOF

    chmod +x "$wrapper_path"
    
    # Create symlink in local bin
    mkdir -p "$LOCAL_BIN"
    ln -sf "$wrapper_path" "$LOCAL_BIN/nvim-$profile_name"

    log_success "Created Neovim wrapper: nvim-$profile_name"
}

list_profiles() {
    if [ -d "$NVPM_PROFILES" ]; then
        log_info "Available Neovim profiles:"
        ls -1 "$NVPM_PROFILES"
    else
        log_warning "No profiles directory found. Create a profile first."
    fi
}

switch_profile() {
    local profile_name="$1"

    if [ -z "$profile_name" ]; then
        log_error "Profile name is required"
        return 1
    fi

    if [ ! -d "$NVPM_PROFILES/$profile_name" ]; then
        log_error "Profile '$profile_name' does not exist"
        return 1
    fi

    rm -rf "$NVIM_CONFIG_DIR"
    ln -s "$NVPM_PROFILES/$profile_name" "$NVIM_CONFIG_DIR"
    log_success "Switched to profile '$profile_name'"
}

remove_profile() {
    local profile_name="$1"

    if [ -z "$profile_name" ]; then
        log_error "Profile name is required"
        return 1
    fi

    if [ ! -d "$NVPM_PROFILES/$profile_name" ]; then
        log_error "Profile '$profile_name' does not exist"
        return 1
    fi

    rm -rf "$NVPM_PROFILES/$profile_name"
    log_success "Profile '$profile_name' removed"
}

current_profile() {
    if [ -L "$NVIM_CONFIG_DIR" ]; then
        local current_profile
        current_profile=$(readlink "$NVIM_CONFIG_DIR")
        echo "Current active profile: $(basename "$current_profile")"
    else
        echo "No active profile"
    fi
}
