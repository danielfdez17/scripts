#!/usr/bin/bash

set -e

# shellcheck source-path=/utils/utils.sh
. utils.sh
# . "$(dirname "$0")/utils.sh"

# If the current branch is not develop, switch to develop first
current_branch=$(git branch --show-current)

if [ "$current_branch" != "main" ]; then
  print_warning "Switching to main branch first..."
  git switch main > /dev/null || { print_error "Failed to switch to main branch. Please ensure it exists and you have permission."; exit 1; }
fi

print_warning "Merging develop branch into main branch..."

echo
print_info "Switching to main branch..."
git switch main > /dev/null || { print_error "Failed to switch to main branch. Please ensure it exists and you have permission."; exit 1; }
echo 
print_info "Merging develop branch into main branch..."
git merge develop || { print_error "Failed to merge develop branch into main branch. Please resolve any conflicts and try again."; exit 1; }
echo 
print_info "Pushing changes to remote main branch..."
git push -u origin main;

echo 
print_success "Successfully merged develop branch into main branch."