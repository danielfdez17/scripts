#!/bin/bash

set -e

if [ -z "$1" ]; then
  error_msg="No branch name provided. Please specify the branch to push as an argument."
  print_error "$error_msg" || echo "$error_msg"
  exit 1
fi

current_branch=$1

pushing_branch_msg="Preparing to push $current_branch to origin..."
print_info "$pushing_branch_msg" || echo "$pushing_branch_msg"
error_pushing_branch_msg="Failed to push $current_branch to origin. Please ensure you have permission and try again."
git push origin HEAD:"$current_branch" || { print_error "$error_pushing_branch_msg" || echo "$error_pushing_branch_msg"; exit 1; }

success_msg="Successfully pushed $current_branch to origin."
print_ok "$success_msg" || echo "$success_msg"