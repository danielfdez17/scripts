#!/usr/bin/bash

set -e

# Utility functions for scripts

RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_error() {
    echo -e "$RED✗ $1 $NC"
}

print_info() {
    echo -e "$CYANℹ $1 $NC"
}

print_success() {
    echo -e "$GREEN🗸 $1 $NC"
}

print_warning() {
    echo -e "$YELLOW⚠ $1 $NC"
}