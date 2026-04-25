#!/bin/bash

set -e

# Check if shellcheck is installed
if ! command -v shellcheck &> /dev/null; then
    print_error "shellcheck could not be found. Please install it to lint bash scripts."
    print_info "You can install shellcheck using your package manager (e.g., sudo apt install shellcheck)"
    exit 1
fi

# Find all .sh files in the project and lint them
print_info "Linting bash scripts with shellcheck..."
find . -type f -name "*.sh" -not -path "./node_modules/*" -not -path "./dist/*" -not -path "./build/*" | while read -r script; do
    print_info "Linting $script..."
    shellcheck -x "$script" || { print_error "Linting failed for $script. Please fix the issues and try again."; continue; }
    print_ok "No issues found in $script"
done