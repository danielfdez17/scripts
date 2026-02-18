#!/bin/bash

echo "Installing Git..."
sudo apt install git -y

echo "Creating Git aliases..."
alias ga='git add'
alias gbr='git branch'
alias gc='git commit -m'
alias gl='git log --graph --oneline --decorate'
alias gls='git ls-files'
alias gm='git merge'
alias gp='git push'
alias gpr='git pull --rebase'
alias grep='grep --color=auto'
alias gss='git status -s'
alias gw='git worktree'
