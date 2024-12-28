#!/usr/bin/env bash

select_distribution() {
    echo "Select a distribution:"
    select dist in "vanilla" "astronvim" "nvchad" "lazyvim" "kickstart" "lunarvim"; do
        case $dist in
            "vanilla"|"astronvim"|"nvchad"|"lazyvim"|"kickstart"|"lunarvim")
                echo $dist
                return
                ;;
            *)
                echo "Invalid selection"
                ;;
        esac
    done
}
