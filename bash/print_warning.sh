#!/usr/bin/bash

print_warning() {
    local yellow='\033[1;33m'
    local nc='\033[0m'
    echo -e "${yellow}⚠ ${1} ${nc}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    set -e
    print_warning "$1"
fi
