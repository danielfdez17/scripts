# Alias to reduce the time invested in daily tasks

## General purpose
```bash
alias ..='cd ..'
alias ...='cd ../..'
```

## Git
```bash
alias ga='git add'
alias gbr='git branch'
alias gc='git commit -m'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'
alias gls='git ls-files'
alias gm='git merge'
alias gp='git push'
alias gpr='git pull --rebase'
alias grv='git remote -v'
alias gss='git status -s'
alias gw='git worktree'
alias gf='git fetch'
```
---

## Makefile
### This makes the make execution go faster
```bash
alias make='make -j$(nproc)'
```
---

## K8s
```bash
alias kubectl="minikube kubectl --"
```
