#!/bin/bash

set -e

if [ -z "$1" ]; then
    input_error="Please provide at least one branch name as an argument."
    print_error "$input_error" || echo "Error: $input_error"
    exit 1
fi

for i in "$@"; do
    deleting_branch_msg="Deleting remote branch '$i'..."
    print_info "$deleting_branch_msg" || echo "$deleting_branch_msg"
    deleting_branch_error="Failed to delete remote branch '$i'. Please ensure you have permission and try again."
    git push origin --delete "$i" || { print_error "$deleting_branch_error" || echo "Error: $deleting_branch_error"; continue; }
    deleting_branch_success="Successfully deleted remote branch '$i'."
    print_ok "$deleting_branch_success" || echo "$deleting_branch_success"
done