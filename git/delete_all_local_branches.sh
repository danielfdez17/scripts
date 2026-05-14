#!/bin/bash

set -e

delete_all_local_branches_msg="Deleting all local branches except main and develop..."
print_info "$delete_all_local_branches_msg" || echo "$delete_all_local_branches_msg"

warning_msg="This will permanently delete all local branches except main and develop. Please ensure you have pushed any important changes to remote before proceeding."
print_warning "$warning_msg" || echo "$warning_msg"

read -rp "Are you sure you want to proceed? (y/n) " confirmation

if [[ $confirmation == "y" ]]; then
    git branch | grep -v "main\|develop" | xargs git branch -D
    success_msg="All local branches except main and develop have been deleted."
    print_ok "$success_msg" || echo "$success_msg"
else
    cancel_msg="Operation cancelled. No branches were deleted."
    print_info "$cancel_msg" || echo "$cancel_msg"
fi