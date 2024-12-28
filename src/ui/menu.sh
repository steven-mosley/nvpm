#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all distribution installers
if [ -d "$SCRIPT_DIR/../distributions" ]; then
    for installer in "$SCRIPT_DIR/../distributions/"*.sh; do
        if [ -f "$installer" ]; then
            source "$installer"
        fi
    done
else
    log_error "Distributions directory not found: $SCRIPT_DIR/../distributions/"
    exit 1
fi

select_distribution() {
    local options=("vanilla" "astronvim" "nvchad" "lazyvim" "kickstart" "lunarvim")
    local PS3="Please select a distribution (1-${#options[@]}): "
    local choice

    # Don't echo "Select a distribution:" here since it's getting mixed into the return value
    select choice in "${options[@]}"; do
        if [[ -n "$choice" ]]; then
            printf "%s" "$choice"  # Use printf instead of echo to avoid newline issues
            return 0
        else
            echo "Invalid selection. Please enter a number between 1 and ${#options[@]}"
        fi
    done
}
