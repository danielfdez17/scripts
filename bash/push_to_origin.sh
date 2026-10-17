#!/usr/bin/bash

set -e

script_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=utils.sh
. "${script_dir}/utils.sh"

current_branch=$(git branch --show-current)

print_info "Pushing $current_branch to origin..."

git push -u origin "$current_branch" || { print_error "Failed to push $current_branch to origin. Please ensure you have permission and try again."; exit 1; }

print_success "Successfully pushed $current_branch to origin."