#!/bin/bash

set -e

# If the current branch is not develop, switch to develop first
current_branch=$(git branch --show-current)

if [ "$current_branch" == "develop" ]; then
  already_on_develop_msg="Already on develop branch"
  print_warning "$already_on_develop_msg" || echo "$already_on_develop_msg"
  exit 0
fi

merge_warning_msg="The current branch is $current_branch, which will be merged into develop and then deleted from remote."
print_warning "$merge_warning_msg" || echo "$merge_warning_msg"

echo
switching_to_develop_msg="Switching to develop branch..."
print_info "$switching_to_develop_msg" || echo "$switching_to_develop_msg"
error_when_switching_msg="Failed to switch to develop branch. Please ensure it exists and you have permission."
git switch develop > /dev/null || { print_error "$error_when_switching_msg" || echo "$error_when_switching_msg"; exit 1; }
echo 
delete_remote_branch_msg="Deleting remote branch $current_branch..."
print_info "$delete_remote_branch_msg" || echo "$delete_remote_branch_msg"
error_deleting_remote_branch_msg="Failed to delete remote branch $current_branch. It may not exist or you may not have permission."
git push --delete origin "$current_branch" || { print_error "$error_deleting_remote_branch_msg" || echo "$error_deleting_remote_branch_msg"; exit 1; }
echo 
merge_msg="Merging $current_branch into develop..."
print_info "$merge_msg" || echo "$merge_msg"
error_merging_msg="Failed to merge $current_branch into develop. Please resolve any conflicts and try again."
git merge "$current_branch" || { print_error "$error_merging_msg" || echo "$error_merging_msg"; exit 1; }
# echo 
# delete_local_branch_msg="Deleting local branch $current_branch..."
# print_info "$delete_local_branch_msg" || echo "$delete_local_branch_msg"
# echo
# error_deleting_local_branch_msg="Failed to delete local branch $current_branch. Please ensure it is not currently checked out and try again."
# git branch -D "$current_branch" || { print_error "$error_deleting_local_branch_msg" || echo "$error_deleting_local_branch_msg"; exit 1; }
echo 
pushing_changes_msg="Pushing changes to remote develop branch..."
print_info "$pushing_changes_msg" || echo "$pushing_changes_msg"
git push -u origin develop;

echo 
success_msg="Successfully merged $current_branch into develop and deleted the remote branch."
print_ok "$success_msg" || echo "$success_msg"