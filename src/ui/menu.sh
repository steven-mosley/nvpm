#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../core/logging.sh"
source "${BASH_SOURCE%/*}/../core/config.sh"

select_distribution() {
    echo "Select Neovim Distribution:"
    echo "1) Vanilla Neovim"
    echo "2) AstroNvim"
    echo "3) NvChad"
    echo "4) LazyVim"
    echo "5) kickstart.nvim"
    echo "6) LunarVim"
    echo
    read -p "Enter selection [1-6]: " selection

    case $selection in
        1) echo "vanilla";;
        2) echo "astronvim";;
        3) echo "nvchad";;
        4) echo "lazyvim";;
        5) echo "kickstart";;
        6) echo "lunarvim";;
        *) 
            log_error "Invalid selection"
            return 1
            ;;
    esac
}
