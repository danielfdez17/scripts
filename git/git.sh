#!/bin/bash

. "$(dirname "$0")/../utils/colors.sh"

# Check if git is installed
if ! command -v git &> /dev/null
then
    print_error "Git is not installed. You should install Git in order to use the git aliases."
else
    print_ok "Git is installed."
fi

setup_git_aliases() {
    print_info "Setting up Git aliases..."
    alias gss='git status -s'
    alias ga='git add'
    alias gc='git commit -m'
    alias gp='git push'
    alias gl='git log --oneline --graph --decorate'
    alias gpr='git pull --rebase'
    alias gls='git ls-files'
    alias grv='git remote -v'
    alias gco='git checkout'
    alias gbr='git branch'
    print_ok "All aliases have been configured"
}

setup_git_aliases


