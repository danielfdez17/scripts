#!/bin/bash

set -e

. "$(dirname "$0")/utils.sh"

files=$(find . -maxdepth 1 -name ".env" -type f)

print_info "Checking for .env files..."

if [ -z "$files" ]; then
  print_error "No .env file found. Please create a .env file with the necessary environment variables."
  exit 1
fi

print_success " .env file found."