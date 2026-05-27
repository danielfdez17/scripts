#!/usr/bin/bash

mkdir -p ~/projects/transcendence
cd ~/projects/transcendence || exit 0

repositories=(
  ft_transcendence
  osionos
  osionos-mail
  osionos-calendar
  notion-database-sys
  formula-engine
  mini-baas-infra
  osionos-canvas
  mini-baas-sdk
  markengine
  prismatica-landing
  UI-Collection
  realtime-agnostic
  adapter-registry-api
  mongo-api
  storage-router-api
  email-api
  DoD
  QA
  monkey-bot
  libcss
  prismatica
  transcendence
  mini-baas
)

for repo in "${repositories[@]}"; do
  if [ -d "$repo" ]; then
    cd "$repo" || exit 0
    git pull --rebase origin main
    cd ..
  else
    git clone "git@github.com:Univers42/$repo"
  fi
done
