#!/bin/bash

set -e

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"
OK="$GREEN🗸$RESET"
ERROR="$RED✗$RESET"
WARNING="$YELLOW⚠$RESET"

# If the current branch is not develop, switch to develop first
current_branch=$(git branch --show-current)

if [ "$current_branch" == "develop" ]; then
  echo -e "$WARNING Already on develop branch."
  exit 0
fi

echo -e "$WARNING The current branch is $current_branch, which will be merged into develop and then deleted from remote."


echo
echo "Switching to develop branch..."
git switch develop > /dev/null || { echo -e "$ERROR Failed to switch to develop branch. Please ensure it exists and you have permission."; exit 1; }
echo 
echo "Deleting remote branch $current_branch..."
git push --delete origin "$current_branch" || { echo -e "$ERROR Failed to delete remote branch $current_branch. It may not exist or you may not have permission."; exit 1; }
echo 
echo "Merging $current_branch into develop..."
git merge "$current_branch" || { echo -e "$ERROR Failed to merge $current_branch into develop. Please resolve any conflicts and try again."; exit 1; }
# echo 
# echo "Deleting local branch $current_branch..."
# git branch -D "$current_branch" || { echo -e "$ERROR Failed to delete local branch $current_branch. Please ensure it is not currently checked out and try again."; exit 1; }
echo 
echo "Pushing changes to remote develop branch..."
git push -u origin develop;

echo 
echo -e "$OK Successfully merged $current_branch into develop and deleted the remote branch."