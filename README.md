# NeoVim Profile Manager
This is a work in progress. This is a profile manager that uses [NVIM_APPNAME](https://neovim.io/doc/user/starting.html#_nvim_appname) to create isolated Neovim profiles.

> [!NOTE]
> Currently this app is not functional. You may however still attempt to use it, fork it, and turn it into your own.

## Vision
The idea is to have a profile manager for Neovim to easily switch between Neovim profiles in an intuitive way instead of relying on manually creating
aliases in your shell config. Additionally, it supports the common Neovim distributions with the option to automatically install that distributon.

## Example
```bash
$ nvpm create astronvim
INFO: Fetching the latest scripts from GitHub...
SUCCESS: Fetched the latest scripts from GitHub
INFO: Creating new profile: astronvim
1) vanilla
2) astronvim
3) nvchad
4) lazyvim
5) kickstart
6) lunarvim
#? 2
INFO: Installing AstroNvim
SUCCESS: AstroNvim has been installed.
Set AstroNvim as your system default
with `nvpm switch astronvim` and launch
it with `nvim`.
```
## Working Prototype
There is a working prototype that you may use.
```bash
#!/bin/bash

NVPM_ROOT="$HOME/.nvpm"
NVPM_SHIMS="$NVPM_ROOT/shims"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN="$HOME/.local/bin"

usage() {
    echo "Neovim Profile Manager (nvpm)"
    echo
    echo "Usage:"
    echo "  nvpm setup                  - First-time setup of nvpm environment"
    echo "  nvpm create <profile-name>  - Create a new profile directory and wrapper"
    echo "  nvpm list                   - List all available profiles"
    echo "  nvpm switch <profile-name>  - Set default profile for 'nvim' command"
    echo "  nvpm current               - Show current default profile"
    echo "  nvpm doctor                - Check nvpm configuration and environment"
    echo "  nvpm help                  - Show this help message"
    echo
    echo "Direct profile access:"
    echo "  After creating a profile, you can use it directly with 'nvim-<profile-name>'"
    echo "  Example: nvim-lazyvim, nvim-astrovim"
}

create_profile() {
    local profile_name="$1"

    if [ -z "$profile_name" ]; then
        echo "Error: Profile name is required"
        exit 1
    fi

    local profile_dir="$CONFIG_DIR/$profile_name"

    echo "Checking profile directory: $profile_dir"

    if [ -d "$profile_dir" ]; then
        echo "Warning: Directory already exists: $profile_dir"
        echo "Using existing directory..."
    else
        echo "Creating profile directory at: $profile_dir"
        mkdir -p "$profile_dir"
    fi

    # Create a minimal init.lua if no config exists
    if [ ! -f "$profile_dir/init.lua" ] && [ ! -f "$profile_dir/init.vim" ]; then
        echo "Creating minimal init.lua..."
        cat > "$profile_dir/init.lua" << 'EOF'
-- Minimal init.lua
vim.opt.compatible = false
vim.cmd('filetype plugin indent on')
vim.opt.syntax = 'on'
EOF
        echo "Created minimal init.lua"
    fi

    # Create shim directory if it doesn't exist
    mkdir -p "$NVPM_SHIMS"

    # First find the real system nvim
    local system_nvim
    system_nvim=$(which -a nvim | grep "^/usr/\|^/bin/" | head -n 1)

    if [ -z "$system_nvim" ]; then
        echo "Error: Could not find system nvim"
        exit 1
    fi

    # Create the profile-specific wrapper
    local wrapper_path="$NVPM_SHIMS/nvim-$profile_name"
    cat > "$wrapper_path" << EOF
#!/usr/bin/env bash
exec env NVIM_APPNAME="$profile_name" "$system_nvim" "\$@"
EOF
    chmod +x "$wrapper_path"

    # Create symlink in local bin
    mkdir -p "$LOCAL_BIN"
    ln -sf "$wrapper_path" "$LOCAL_BIN/nvim-$profile_name"

    echo "Profile '$profile_name' is ready to use"
    echo "You can run it with: nvim-$profile_name"
    echo "System nvim found at: $system_nvim"
}

switch_profile() {
    local profile_name="$1"

    if [ -z "$profile_name" ]; then
        echo "Error: Profile name is required"
        exit 1
    fi

    # Check if profile exists
    if [ ! -d "$CONFIG_DIR/$profile_name" ]; then
        echo "Error: Profile '$profile_name' does not exist"
        exit 1
    fi

    # Check if profile wrapper exists
    if [ ! -f "$NVPM_SHIMS/nvim-$profile_name" ]; then
        echo "Error: Profile wrapper does not exist. Try recreating the profile"
        exit 1
    fi

    # Create/update the nvim symlink in shims directory
    ln -sf "$NVPM_SHIMS/nvim-$profile_name" "$NVPM_SHIMS/nvim"

    # Create/update the global nvim symlink to point to the shim
    mkdir -p "$LOCAL_BIN"
    ln -sf "$NVPM_SHIMS/nvim" "$LOCAL_BIN/nvim"

    echo "Set default profile to '$profile_name'"
    echo "The 'nvim' command will now use this profile"
}

get_current_profile() {
	if [ -L "$LOCAL_BIN/nvim" ]; then
		local target=$(readlink "$LOCAL_BIN/nvim")
		basename "$target" | sed 's/^nvim-//'
	fi
}

show_current_profile() {
	local current_profile=$(get_current_profile)
	if [ -n "$current_profile" ]; then
		echo "Current default profile: $current_profile"
	else
		echo "No default profile set"
	fi
}

list_profiles() {
	echo "Available profiles:"
	local current_profile=$(get_current_profile)
	local found_profiles=0

	# List all profile directories
	for dir in "$CONFIG_DIR"/*; do
		if [ -d "$dir" ]; then
			profile_name=$(basename "$dir")
			status=""

			# Check if wrapper exists
			if [ -f "$NVPM_SHIMS/nvim-$profile_name" ]; then
				if [ -f "$dir/init.lua" ]; then
					status=" (lua)"
				elif [ -f "$dir/init.vim" ]; then
					status=" (vim)"
				else
					status=" (empty)"
				fi

				if [ "$profile_name" = "$current_profile" ]; then
					echo "* $profile_name$status (default)"
				else
					echo "  $profile_name$status"
				fi
				found_profiles=1
			fi
		fi
	done

	if [ $found_profiles -eq 0 ]; then
		echo "No profiles found."
		echo
		echo "To create a new profile, use: nvpm create <profile-name>"
	fi
}

setup_nvpm() {
    # Create necessary directories
    mkdir -p "$NVPM_ROOT"
    mkdir -p "$NVPM_SHIMS"
    mkdir -p "$LOCAL_BIN"

    # Create the shell initialization script
    cat > "$NVPM_ROOT/nvpm.sh" << 'EOF'
export NVPM_ROOT="$HOME/.nvpm"
export PATH="$NVPM_ROOT/shims:$PATH"
EOF

    # Also create fish version if needed
    mkdir -p "$NVPM_ROOT/conf.d"
    cat > "$NVPM_ROOT/conf.d/nvpm.fish" << 'EOF'
set -gx NVPM_ROOT "$HOME/.nvpm"
fish_add_path -p "$NVPM_ROOT/shims"
EOF

    # Detect shell and configure accordingly
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
            # Ensure fish config directory exists
            mkdir -p "$(dirname "$rcfile")"
            # Alternatively, we could symlink the conf.d file to fish's conf.d directory
            # mkdir -p "$HOME/.config/fish/conf.d"
            # ln -sf "$NVPM_ROOT/conf.d/nvpm.fish" "$HOME/.config/fish/conf.d/nvpm.fish"
            ;;
        *)
            echo "Warning: Unrecognized shell '$shell_type'. Defaulting to bash configuration."
            rcfile="$HOME/.bashrc"
            init_command='[ -f "$HOME/.nvpm/nvpm.sh" ] && source "$HOME/.nvpm/nvpm.sh"'
            shell_name="bash"
            ;;
    esac

    # Add shell initialization if not already present
    if [ -f "$rcfile" ]; then
        if ! grep -q "nvpm.*sh" "$rcfile"; then
            echo "Adding nvpm initialization to $rcfile..."
            echo '' >> "$rcfile"
            echo '# nvpm initialization' >> "$rcfile"
            echo "$init_command" >> "$rcfile"
        else
            echo "nvpm initialization already present in $rcfile"
        fi
    else
        echo "Creating $rcfile with nvpm initialization..."
        echo "$init_command" > "$rcfile"
    fi

    # Create the nvpm command in local bin if it doesn't exist
    if [ ! -f "$LOCAL_BIN/nvpm" ]; then
        ln -sf "$0" "$LOCAL_BIN/nvpm"
    fi

    echo "NVPM setup complete!"
    echo "Initialization added for $shell_name shell in: $rcfile"
    echo
    echo "Please restart your shell or run:"
    case "$shell_name" in
        "fish")
            echo "  source $rcfile"
            ;;
        *)
            echo "  source $rcfile"
            ;;
    esac
    echo
    echo "To verify installation, run:"
    echo "  nvpm doctor"
}

doctor() {
	echo "Running diagnostics..."
	echo

	echo "1. Checking NVPM installation:"
	[ -d "$NVPM_ROOT" ] && echo "  ✓ NVPM root exists: $NVPM_ROOT" || echo "  ✗ NVPM root missing"
	[ -d "$NVPM_SHIMS" ] && echo "  ✓ Shims directory exists: $NVPM_SHIMS" || echo "  ✗ Shims directory missing"
	echo

	echo "2. Checking PATH configuration:"
	if [[ ":$PATH:" == *":$LOCAL_BIN:"* ]]; then
		echo "  ✓ $LOCAL_BIN is in PATH"
	else
		echo "  ✗ $LOCAL_BIN is not in PATH"
	fi
	echo

	echo "3. Checking system Neovim:"
	local system_nvim=$(which -a nvim | grep -v "$NVPM_SHIMS" | head -n 1)
	[ -n "$system_nvim" ] && echo "  ✓ System Neovim found: $system_nvim" || echo "  ✗ System Neovim not found"
	echo

	echo "4. Checking profiles:"
	local current_profile=$(get_current_profile)
	echo "  Current profile: ${current_profile:-none}"
	echo "  Available profiles:"
	for dir in "$CONFIG_DIR"/*; do
		if [ -d "$dir" ]; then
			profile_name=$(basename "$dir")
			if [ -f "$NVPM_SHIMS/nvim-$profile_name" ]; then
				echo "    ✓ $profile_name (wrapper exists)"
			else
				echo "    ✗ $profile_name (no wrapper)"
			fi
		fi
	done
}

case "$1" in
"create")
	create_profile "$2"
	;;
"list")
	list_profiles
	;;
"switch")
	switch_profile "$2"
	;;
"current")
	show_current_profile
	;;
"doctor")
	doctor
	;;
"setup")
	setup_nvpm
	;;
"help" | "--help" | "-h" | "")
	usage
	;;
*)
	echo "Unknown command: $1"
	usage
	exit 1
	;;
esac
```
Save the above code in `~./local/bin/nvpm`, and make it executable with `chmod +x ~/.local/bin/nvpm`.

Finally, add this location to your path:

**Bash**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

**Zsh**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```
