#!/bin/bash

set -e

. "$(dirname "$0")/../utils/colors.sh"

# If the current branch is not develop, switch to develop first
current_branch=$(git branch --show-current)

if [ "$current_branch" == "develop" ]; then
  print_warning "Already on develop branch."
  exit 0
fi

print_warning "The current branch is $current_branch, which will be merged into develop and then deleted from remote."

echo
print_info "Switching to develop branch..."
git switch develop > /dev/null || { print_error "Failed to switch to develop branch. Please ensure it exists and you have permission."; exit 1; }
echo 
print_info "Deleting remote branch $current_branch..."
git push --delete origin "$current_branch" || { print_error "Failed to delete remote branch $current_branch. It may not exist or you may not have permission."; exit 1; }
echo 
print_info "Merging $current_branch into develop..."
git merge "$current_branch" || { print_error "Failed to merge $current_branch into develop. Please resolve any conflicts and try again."; exit 1; }
# echo 
# echo "Deleting local branch $current_branch..."
# git branch -D "$current_branch" || { print_error "Failed to delete local branch $current_branch. Please ensure it is not currently checked out and try again."; exit 1; }
echo 
print_info "Pushing changes to remote develop branch..."
git push -u origin develop;

echo 
print_ok "Successfully merged $current_branch into develop and deleted the remote branch."