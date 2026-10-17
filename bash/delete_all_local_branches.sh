#!/usr/bin/bash

set -e

script_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=utils.sh
. "${script_dir}/utils.sh"

print_info "Deleting all local branches except main and develop..."

print_warning "This will permanently delete all local branches except main and develop. Please ensure you have pushed any important changes to remote before proceeding."

local_branches=$(git branch | grep -v "main\|develop")
print_info "The following local branches will be deleted:\n$local_branches"

read -rp "Are you sure you want to proceed? (y/n) " confirmation

if [[ $confirmation == "y" ]]; then
    git branch | grep -v "main\|develop" | xargs git branch -D
    print_success "All local branches except main and develop have been deleted."
else
    print_info "Operation cancelled. No branches were deleted."
fi