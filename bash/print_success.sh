#!/usr/bin/bash

print_success() {
    local green='\033[0;32m'
    local nc='\033[0m'
    echo -e "${green}✓ ${1} ${nc}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    set -e
    print_success "$1"
fi
