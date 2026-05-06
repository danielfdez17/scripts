#!/bin/bash

set -e

# Check if shellcheck is installed
if ! command -v shellcheck &> /dev/null; then
    shellcheck_error_msg="shellcheck could not be found. Please install it to lint bash scripts."
    print_error "$shellcheck_error_msg" || echo "$shellcheck_error_msg"
    shellcheck_install_msg="You can install shellcheck using your package manager (e.g., sudo apt install shellcheck)"
    print_info "$shellcheck_install_msg" || echo "$shellcheck_install_msg"
    exit 1
fi

# Find all .sh files in the project and lint them
linting_msg="Linting bash scripts with shellcheck..."
print_info "$linting_msg" || echo "$linting_msg"
find . -type f -name "*.sh" -not -path "./node_modules/*" -not -path "./dist/*" -not -path "./build/*" | while read -r script; do
    linting_script_msg="Linting $script..."
    print_info "$linting_script_msg" || echo "$linting_script_msg"
    error_linting_msg="Linting failed for $script. Please fix the issues and try again."
    shellcheck -x "$script" || { print_error "$error_linting_msg" || echo "$error_linting_msg"; continue; }
    success_linting_msg="No issues found in $script."
    print_ok "$success_linting_msg" || echo "$success_linting_msg"
done