#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/logging.sh"
source "${BASH_SOURCE%/*}/config.sh"
source "${BASH_SOURCE%/*}/../ui/menu.sh"

create_profile_wrapper() {
    local profile_name="$1"
    local wrapper_dir="$NVPM_ROOT/wrappers"
    local wrapper_path="$wrapper_dir/$profile_name"

    mkdir -p "$wrapper_dir"

    cat << EOF > "$wrapper_path"
#!/usr/bin/env bash
export NVIM_APPNAME="nvpm/$profile_name"
/usr/bin/nvim "\$@"
EOF

    chmod +x "$wrapper_path"
    log_success "Profile wrapper created: $wrapper_path"
}

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
        log_error "No distribution type selected"
        return 1
    fi

    local config_dir="$HOME/.config/nvpm/$profile_name"

    case "$dist_type" in
        "vanilla")
            create_vanilla_profile "$config_dir"
            ;;
        "astronvim")
            install_astronvim "$config_dir"
            ;;
        "nvchad")
            install_nvchad "$config_dir"
            ;;
        "lazyvim")
            install_lazyvim "$config_dir"
            ;;
        "kickstart")
            install_kickstart "$config_dir"
            ;;
        "lunarvim")
            install_lunarvim "$config_dir"
            ;;
        *)
            log_error "Unknown distribution type: $dist_type"
            return 1
            ;;
    esac

    # Create profile wrapper script
    create_profile_wrapper "$profile_name"

    log_success "Profile '$profile_name' created successfully!"
}

switch_profile() {
    local profile_name="$1"
    local wrapper_path="$NVPM_ROOT/wrappers/$profile_name"
    local nvim_symlink="/usr/local/bin/nvim"

    if [ ! -f "$wrapper_path" ]; then
        log_error "Profile wrapper does not exist for '$profile_name'"
        return 1
    fi

    if [ -L "$nvim_symlink" ]; then
        rm "$nvim_symlink"
    fi

    ln -s "$wrapper_path" "$nvim_symlink"
    log_success "Switched to profile '$profile_name' globally"
}
