#!/usr/bin/bash

print_info() {
    local cyan='\033[0;36m'
    local nc='\033[0m'
    echo -e "${cyan}ℹ ${1} ${nc}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    set -e
    print_info "$1"
fi
