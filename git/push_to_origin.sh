#!/bin/bash

set -e

current_branch=$(git branch --show-current)

pushing_branch_msg="Pushing $current_branch to origin..."
print_info "$pushing_branch_msg" || echo "$pushing_branch_msg"
error_pushing_branch_msg="Failed to push $current_branch to origin. Please ensure you have permission and try again."
git push -u origin "$current_branch" || { print_error "$error_pushing_branch_msg" || echo "$error_pushing_branch_msg"; exit 1; }

success_msg="Successfully pushed $current_branch to origin."
print_ok "$success_msg" || echo "$success_msg"