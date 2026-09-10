#!/usr/bin/bash

set -e

. "$(dirname "$0")/utils.sh"

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
total_scripts=0
successful_lints=0
failed_lints=0
# Use process substitution so loop counters are updated in the current shell.
while read -r script; do
    total_scripts=$((total_scripts + 1))
    linting_script_msg="Linting $script..."
    print_info "$linting_script_msg" || echo "$linting_script_msg"
    error_linting_msg="Linting failed for $script. Please fix the issues and try again."
    shellcheck -x "$script" || { print_error "$error_linting_msg" || echo "$error_linting_msg"; failed_lints=$((failed_lints + 1)); continue; }
    success_linting_msg="No issues found in $script."
    print_success "$success_linting_msg" || echo "$success_linting_msg"
    successful_lints=$((successful_lints + 1))
done < <(find . -type f -name "*.sh" -not -path "./node_modules/*" -not -path "./dist/*" -not -path "./build/*")

summary_msg="Linting complete: $successful_lints successful, $failed_lints failed, out of $total_scripts scripts."
if [ "$failed_lints" -eq 0 ]; then
    print_success "$summary_msg" || echo "$summary_msg"
else
    print_error "$summary_msg" || echo "$summary_msg"
fi