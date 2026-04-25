#!/bin/bash

set -e

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"
OK="$GREEN🗸"
ERROR="$RED✗"

files=$(find . -maxdepth 1 -name ".env" -type f)

echo -e "Checking for .env files..."

if [ -z "$files" ]; then
  echo -e "$ERROR No .env file found. Please create a .env file with the necessary environment variables.$RESET"
  exit 1
fi

echo -e "$OK .env file found.$RESET"