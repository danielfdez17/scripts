#!/usr/bin/bash

set -e

. "$(dirname "$0")/utils.sh"

print_info "Updating submodules..."
git submodule update --init --recursive --remote

echo 
print_success "Successfully updated submodules."