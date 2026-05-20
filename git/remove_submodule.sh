#!/bin/bash

set -e

if [ ! -d ".git" ]; then
    error_msg="This script must be run from the root of a git repository."
    print_error "$error_msg" || echo "$error_msg"
    exit 1
fi

if [ -z "$1" ]; then
    error_msg="Please provide the relative path of the submodule to remove as an argument."
    print_error "$error_msg" || echo "$error_msg"
    exit 1
fi

removing_submodule_msg="Removing submodule '$1'..."
print_info "$removing_submodule_msg" || echo "$removing_submodule_msg"

deinit_msg="Submodule '$1' deinitialized."
error_deinit_msg="Failed to deinitialize submodule '$1'. Please ensure the path is correct and try again."
(git submodule deinit -f -- "$1" && (print_ok "$deinit_msg" || echo "$deinit_msg")) || { print_error "$error_deinit_msg" || echo "$error_deinit_msg"; exit 1; }
submodule_directory_msg="Submodule '$1' git directory removed."
error_submodule_directory_msg="Failed to remove submodule's git directory. Please check permissions and try again."
(rm -rf ".git/modules/$1" && (print_ok "$submodule_directory_msg" || echo "$submodule_directory_msg")) || { print_error "$error_submodule_directory_msg" || echo "$error_submodule_directory_msg"; exit 1; }
submodule_index_msg="Submodule '$1' removed from git index."
error_submodule_index_msg="Failed to remove submodule from git index. Please ensure the path is correct and try again."
(git rm -f "$1" && (print_ok "$submodule_index_msg" || echo "$submodule_index_msg")) || { print_error "$error_submodule_index_msg" || echo "$error_submodule_index_msg"; exit 1; }
submodule_directory_removed_msg="Submodule '$1' directory removed."
error_submodule_directory_removed_msg="Failed to remove submodule directory. Please check permissions and try again."
(rm -rf "$1" && (print_ok "$submodule_directory_removed_msg" || echo "$submodule_directory_removed_msg")) || { print_error "$error_submodule_directory_removed_msg" || echo "$error_submodule_directory_removed_msg"; exit 1; }
submodule_removed_from_gitmodules_msg="Submodule '$1' removed from .gitmodules."
(git config -f .gitmodules --remove-section "submodule.$1" && (print_ok "$submodule_removed_from_gitmodules_msg" || echo "$submodule_removed_from_gitmodules_msg")) || true #{ print_error "Failed to remove submodule from .gitmodules. Please ensure the path is correct and try again."; exit 1; }
submodule_removed_from_gitconfig_msg="Submodule '$1' removed from .git/config."
(git config -f .git/config --remove-section "submodule.$1" && (print_ok "$submodule_removed_from_gitconfig_msg" || echo "$submodule_removed_from_gitconfig_msg")) || true #{ print_error "Failed to remove submodule from .git/config. Please ensure the path is correct and try again."; exit 1; }
# (git add .gitmodules && print_ok ".gitmodules updated.") || { print_error "Failed to stage .gitmodules changes. Please check the file and try again."; exit 1; }
# (git commit -m "Remove submodule '$1'" && print_ok "Submodule '$1' removed from git repository.") || { print_error "Failed to commit submodule removal. Please check the git status and try again."; exit 1; }

success_msg="Submodule '$1' removed successfully."
print_ok "$success_msg" || echo "$success_msg"