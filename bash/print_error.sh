#!/usr/bin/bash

print_error() {
    local red='\033[0;31m'
    local nc='\033[0m'
    echo -e "${red}✗ ${1} ${nc}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    set -e
    print_error "$1"
fi
