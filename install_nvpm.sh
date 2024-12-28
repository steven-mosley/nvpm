#!/usr/bin/env bash
#
# NVPM Installer Script
# This script installs NVPM (Neovim Profile Manager) and sets up the environment.

set -e

NVPM_REPO_URL="https://raw.githubusercontent.com/steven-mosley/nvpm/main/nvpm"
INSTALL_DIR="$HOME/.nvpm"
LOCAL_BIN="$HOME/.local/bin"
NVPM_SCRIPT="$LOCAL_BIN/nvpm"

log_info() {
    echo -e "\033[0;34mINFO:\033[0m $1"
}

log_success() {
    echo -e "\033[0;32mSUCCESS:\033[0m $1"
}

log_warning() {
    echo -e "\033[1;33mWARNING:\033[0m $1"
}

log_error() {
    echo -e "\033[0;31mERROR:\033[0m $1" >&2
}

# Ensure necessary directories exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$LOCAL_BIN"

# Download the NVPM script
log_info "Downloading NVPM script..."
curl -fsSL "$NVPM_REPO_URL" -o "$NVPM_SCRIPT"
chmod +x "$NVPM_SCRIPT"
log_success "NVPM script downloaded to $NVPM_SCRIPT"

# Detect shell and configure accordingly
setup_shell() {
    local shell_type
    if [ -n "$SHELL" ]; then
        shell_type=$(basename "$SHELL")
    else
        shell_type=$(basename "$(getent passwd $USER | cut -d: -f7)")
    fi

    local rcfile
    local init_command
    local shell_name

    case "$shell_type" in
        "bash")
            rcfile="$HOME/.bashrc"
            init_command='[ -f "$HOME/.nvpm/nvpm.sh" ] && source "$HOME/.nvpm/nvpm.sh"'
            shell_name="bash"
            ;;
        "zsh")
            rcfile="$HOME/.zshrc"
            init_command='[ -f "$HOME/.nvpm/nvpm.sh" ] && source "$HOME/.nvpm/nvpm.sh"'
            shell_name="zsh"
            ;;
        "fish")
            rcfile="$HOME/.config/fish/config.fish"
            init_command='source "$HOME/.nvpm/conf.d/nvpm.fish"'
            shell_name="fish"
            mkdir -p "$(dirname "$rcfile")"
            ;;
        *)
            log_warning "Unrecognized shell '$shell_type'. Defaulting to bash configuration."
            rcfile="$HOME/.bashrc"
            init_command='[ -f "$HOME/.nvpm/nvpm.sh" ] && source "$HOME/.nvpm/nvpm.sh"'
            shell_name="bash"
            ;;
    esac

    # Add shell initialization if not already present
    if [ -f "$rcfile" ]; then
        if ! grep -q "nvpm.*sh" "$rcfile"; then
            log_info "Adding nvpm initialization to $rcfile..."
            echo '' >> "$rcfile"
            echo '# nvpm initialization' >> "$rcfile"
            echo "$init_command" >> "$rcfile"
        else
            log_info "nvpm initialization already present in $rcfile"
        fi
    else
        log_info "Creating $rcfile with nvpm initialization..."
        echo "$init_command" > "$rcfile"
    fi

    log_success "Shell configured for $shell_name in: $rcfile"
    log_info "Please restart your shell or run:"
    echo "  source $rcfile"
}

# Run the setup function from the NVPM script
log_info "Running NVPM setup..."
"$NVPM_SCRIPT" setup

# Configure the user's shell
setup_shell

log_success "NVPM installation complete!"
log_info "You can now use NVPM with the 'nvpm' command."
log_info "For more information, run 'nvpm help'."
