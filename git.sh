#!/bin/bash

# Check if git is installed
if ! command -v git &> /dev/null
then
    echo "Git is not installed. You should install Git in order to use the git aliases."
    exit 1
else
    echo "Git is installed."
fi

# Git aliases
alias gss='git status -s'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gpr='git pull --rebase'
alias gls='git ls-files'
alias grv='git remote -v'