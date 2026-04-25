#!/bin/bash

set -e

if [ ! -d ".git" ]; then
    print_error "This script must be run from the root of a git repository."
    exit 1
fi

if [ -z "$1" ]; then
    print_error "Please provide the relative path of the submodule to remove as an argument."
    exit 1
fi

print_info "Removing submodule '$1'..."

(git submodule deinit -f -- "$1" && print_ok "Submodule '$1' deinitialized.") || { print_error "Failed to deinitialize submodule '$1'. Please ensure the path is correct and try again."; exit 1; }
(rm -rf ".git/modules/$1" && print_ok "Submodule '$1' git directory removed.") || { print_error "Failed to remove submodule's git directory. Please check permissions and try again."; exit 1; }
(git rm -f "$1" && print_ok "Submodule '$1' removed from git index.") || { print_error "Failed to remove submodule from git index. Please ensure the path is correct and try again."; exit 1; }
(rm -rf "$1" && print_ok "Submodule '$1' directory removed.") || { print_error "Failed to remove submodule directory. Please check permissions and try again."; exit 1; }
(git config -f .gitmodules --remove-section "submodule.$1" && print_ok "Submodule '$1' removed from .gitmodules.") || true #{ print_error "Failed to remove submodule from .gitmodules. Please ensure the path is correct and try again."; exit 1; }
(git config -f .git/config --remove-section "submodule.$1" && print_ok "Submodule '$1' removed from .git/config.") || true #{ print_error "Failed to remove submodule from .git/config. Please ensure the path is correct and try again."; exit 1; }
# (git add .gitmodules && print_ok ".gitmodules updated.") || { print_error "Failed to stage .gitmodules changes. Please check the file and try again."; exit 1; }
# (git commit -m "Remove submodule '$1'" && print_ok "Submodule '$1' removed from git repository.") || { print_error "Failed to commit submodule removal. Please check the git status and try again."; exit 1; }

print_ok "Submodule '$1' removed successfully."