#!/bin/bash

set -e

if [ -z "$1" ]; then
  print_error "No branch name provided. Please specify the branch to push as an argument."
  exit 1
fi

current_branch=$1

print_info "Pushing $current_branch to origin..."
git push origin HEAD:"$current_branch" || { print_error "Failed to push $current_branch to origin. Please ensure you have permission and try again."; exit 1; }

print_ok "Successfully pushed $current_branch to origin."