#!/usr/bin/env bash

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all distribution installers
for installer in "$SCRIPT_DIR/../distributions/"*.sh; do
    if [ -f "$installer" ]; then
        source "$installer"
    else
        echo "No distribution scripts found in $SCRIPT_DIR/../distributions/"
        exit 1
    fi
done

select_distribution() {
    local options=("vanilla" "astronvim" "nvchad" "lazyvim" "kickstart" "lunarvim")
    local choice

    echo "Select a distribution:"
    select choice in "${options[@]}"; do
        if [[ -n "$choice" ]]; then
            echo "$choice"
            return
        else
            echo "Invalid selection, please try again."
        fi
    done
}
