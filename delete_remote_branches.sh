#!/usr/bin/bash

set -e

. "$(dirname "$0")/utils.sh"

if [ -z "$1" ]; then
    print_error "Please provide at least one branch name as an argument."
    exit 1
fi

for i in "$@"; do
    print_info "Deleting remote branch '$i'..."
    git push origin --delete "$i" || { print_error "Failed to delete remote branch '$i'. Please ensure you have permission and try again."; continue; }
    print_success "Successfully deleted remote branch '$i'."
done