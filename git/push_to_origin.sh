#!/bin/bash

set -e

. "$(dirname "$0")/../utils/colors.sh"

current_branch=$(git branch --show-current)

print_info "Pushing $current_branch to origin..."
git push -u origin "$current_branch" || { print_error "Failed to push $current_branch to origin. Please ensure you have permission and try again."; exit 1; }

print_ok "Successfully pushed $current_branch to origin."