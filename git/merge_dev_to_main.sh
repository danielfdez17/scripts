#!/bin/bash

set -e

# If the current branch is not develop, switch to develop first
current_branch=$(git branch --show-current)

if [ "$current_branch" != "main" ]; then
  already_on_main_msg="Switching to main branch first..."
  print_warning "$already_on_main_msg" || echo "$already_on_main_msg"
  error_when_switching_msg="Failed to switch to main branch. Please ensure it exists and you have permission."
  git switch main > /dev/null || { print_error "$error_when_switching_msg" || echo "$error_when_switching_msg"; exit 1; }
fi

merge_warning_msg="Merging develop branch into main branch..."
print_warning "$merge_warning_msg" || echo "$merge_warning_msg"

echo
switching_to_main_msg="Switching to main branch..."
print_info "$switching_to_main_msg" || echo "$switching_to_main_msg"
error_when_switching_msg="Failed to switch to main branch. Please ensure it exists and you have permission."
git switch main > /dev/null || { print_error "$error_when_switching_msg" || echo "$error_when_switching_msg"; exit 1; }
echo 
merge_msg="Merging develop branch into main branch..."
print_info "$merge_msg" || echo "$merge_msg"
error_merging_msg="Failed to merge develop branch into main branch. Please resolve any conflicts and try again."
git merge develop || { print_error "$error_merging_msg" || echo "$error_merging_msg"; exit 1; }
echo 
pushing_changes_msg="Pushing changes to remote main branch..."
print_info "$pushing_changes_msg" || echo "$pushing_changes_msg"
git push -u origin main;

echo 
success_msg="Successfully merged develop branch into main branch."
print_ok "$success_msg" || echo "$success_msg"