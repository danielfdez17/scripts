#!/bin/bash

. "$(dirname "$0")/../utils/colors.sh"


print_error "This script should receive the name of the 42 student"

# ? Variables
srcs="srcs"
requirements=$srcs"/requirements"
mariadb=$requirements"/mariadb"
nginx=$requirements"/nginx"
wordpress=$requirements"/wordpress"

print_info "Creating volumes folders..."
print_error "Uncomment this lines!"
# sudo mkdir -p /home/danfern3/data/web
# sudo mkdir -p /home/danfern3/data/mariadb
print_error "Uncomment this lines!"

print_info "Creating folder structure..."
mkdir -p "$srcs"
mkdir -p "$requirements"
mkdir -p "$mariadb"
mkdir -p "$nginx"
mkdir -p "$wordpress"

mkdir -p "$wordpress/conf"
mkdir -p "$wordpress/tools"


mkdir -p "$mariadb/conf"
mkdir -p "$mariadb/tools"


mkdir -p "$nginx/conf"
mkdir -p "$nginx/tools"


print_error "There is no Makefile"

# .env (no sobreescribir)

sh scripts/env.sh

print_ok ".env"
