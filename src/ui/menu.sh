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
    local PS3="Please select a distribution (1-${#options[@]}): "  # Add a custom prompt
    local choice

    echo "Select a distribution:"
    select choice in "${options[@]}"; do
        if [[ " ${options[@]} " =~ " ${choice} " ]]; then
            # Valid selection made
            echo "$choice"
            return 0
        elif [[ -n "$REPLY" ]]; then
            # Check if the user entered the name directly
            if [[ " ${options[@]} " =~ " ${REPLY,,} " ]]; then
                echo "${REPLY,,}"
                return 0
            fi
            echo "Invalid selection. Please choose a number between 1 and ${#options[@]}"
        fi
    done
}
