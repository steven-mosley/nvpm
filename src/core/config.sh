#!/usr/bin/env bash

# Base directories
NVPM_ROOT="${NVPM_ROOT:-$HOME/.nvpm}"
NVPM_SHIMS="$NVPM_ROOT/shims"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN="$HOME/.local/bin"
NVPM_VERSION="0.1.0"

# Distribution URLs
declare -A DISTRIBUTION_URLS=(
    ["astronvim"]="https://github.com/AstroNvim/template"
    ["nvchad"]="https://github.com/NvChad/starter"
    ["lazyvim"]="https://github.com/LazyVim/starter"
    ["kickstart"]="https://github.com/nvim-lua/kickstart.nvim.git"
)

# Distribution names for display
declare -A DISTRIBUTION_NAMES=(
    ["astronvim"]="AstroNvim"
    ["nvchad"]="NvChad"
    ["lazyvim"]="LazyVim"
    ["kickstart"]="kickstart.nvim"
    ["lunarvim"]="LunarVim"
    ["vanilla"]="Vanilla Neovim"
)
