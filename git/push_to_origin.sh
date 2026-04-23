#!/bin/bash

set -e

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"
OK="$GREEN🗸"
ERROR="$RED✗"
WARNING="$YELLOW⚠"

current_branch=$(git branch --show-current)

echo "Pushing $current_branch to origin..."
git push -u origin "$current_branch" || { echo -e "$ERROR Failed to push $current_branch to origin. Please ensure you have permission and try again.$RESET"; exit 1; }

echo -e "$OK Successfully pushed $current_branch to origin.$RESET"