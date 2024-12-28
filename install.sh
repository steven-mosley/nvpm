#!/usr/bin/env bash

set -e

# Current version
NVPM_VERSION="0.1.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

log_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

log_error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
}

# Base directories
NVPM_ROOT="${NVPM_ROOT:-$HOME/.nvpm}"
NVPM_BIN="$NVPM_ROOT/bin"
LOCAL_BIN="$HOME/.local/bin"

# Repository URL
NVPM_REPO="https://github.com/steven-mosley/nvpm.git"

# Check for required commands
check_requirements() {
    local missing_deps=()

    # Required dependencies
    local deps=("git" "curl" "nvim")

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Setup shell configuration
setup_shell() {
    local shell_config
    case "$SHELL" in
        */bash)
            shell_config="$HOME/.bashrc"
            ;;
        */zsh)
            shell_config="$HOME/.zshrc"
            ;;
        */fish)
            shell_config="$HOME/.config/fish/config.fish"
            mkdir -p "$(dirname "$shell_config")"
            ;;
        *)
            log_warning "Unknown shell: $SHELL"
            log_info "Please manually add NVPM to your shell configuration"
            return
            ;;
    esac

    # Add NVPM to shell configuration if not already present
    if [ -f "$shell_config" ]; then
        if ! grep -q "NVPM_ROOT" "$shell_config"; then
            echo >> "$shell_config"
            echo '# NVPM initialization' >> "$shell_config"
            echo 'export NVPM_ROOT="$HOME/.nvpm"' >> "$shell_config"
            echo 'export PATH="$NVPM_ROOT/bin:$PATH"' >> "$shell_config"
        fi
    fi
}

install_nvpm() {
    log_info "Installing NVPM..."

    # Create necessary directories
    mkdir -p "$NVPM_ROOT" "$NVPM_BIN" "$LOCAL_BIN"

    # Write the wrapper script
    cat > "$NVPM_BIN/nvpm" << 'EOF'
#!/usr/bin/env bash

set -e

# Define variables
NVPM_ROOT="$HOME/.nvpm"
NVPM_BIN="$NVPM_ROOT/bin"
NVPM_CACHE="$NVPM_ROOT/cache"
NVPM_REPO="https://github.com/steven-mosley/nvpm.git"
NVPM_VERSION="0.1.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

log_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

log_error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
}

# Fetch the latest scripts from GitHub
fetch_latest_scripts() {
    log_info "Fetching the latest scripts from GitHub..."

    # Create necessary directories
    mkdir -p "$NVPM_CACHE"

    # Clone or update the repository in the cache directory
    if [ -d "$NVPM_CACHE/nvpm" ]; then
        git -C "$NVPM_CACHE/nvpm" pull origin main
    else
        git clone "$NVPM_REPO" "$NVPM_CACHE/nvpm"
    fi

    log_success "Fetched the latest scripts from GitHub"
}

# Execute the main script from the fetched repository
execute_script() {
    local script="$1"

    if [ -f "$NVPM_CACHE/nvpm/bin/$script" ]; then
        bash "$NVPM_CACHE/nvpm/bin/$script" "${@:2}"
    else
        log_error "Script '$script' not found in the fetched repository"
        exit 1
    fi
}

# Main entry point
main() {
    # Fetch the latest scripts
    fetch_latest_scripts

    # Execute the main NVPM script
    execute_script "nvpm" "$@"
}

# Run the main function with all arguments
main "$@"
EOF

    chmod +x "$NVPM_BIN/nvpm"

    # Create symlink in local bin
    ln -sf "$NVPM_BIN/nvpm" "$LOCAL_BIN/nvpm"

    # Setup shell integration
    setup_shell

    log_success "NVPM v${NVPM_VERSION} has been installed successfully!"
    log_info "Please restart your shell or run:"
    echo "    source ${shell_config}"
    log_info "To get started, run:"
    echo "    nvpm help"
}

# Main installation process
main() {
    log_info "Welcome to NVPM (Neovim Profile Manager) installer"

    # Check requirements
    check_requirements

    # Perform installation
    install_nvpm
}

main "$@"
