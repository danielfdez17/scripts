#!/bin/bash

# ? Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
INFO=$YELLOW'[INFO]'
OK=$GREEN'[OK]'
ERROR=$RED'[ERROR]'

function print_info {
	echo $INFO "$1" $NC
}

function print_ok {
	echo $OK "$1" $NC
}

function print_error {
	echo $ERROR "$1" $NC
}

print_info "Creating folder structure..."

print_error "There is no Makefile"

# .env (no sobreescribir)
# echo "DOMAIN_NAME=danfern3.42.fr" > "srcs/.env"
# echo >> "srcs/.env"
# echo "# Database config" >> "srcs/.env"
# echo "MARIADB_DATABASE=wordpress" >> "srcs/.env"
# echo "MARIADB_USER=wpuser" >> "srcs/.env"
# echo "MARIADB_PASSWORD=wp_pass" >> "srcs/.env"
# echo "MARIADB_ROOT_PASSWORD=root_pass" >> "srcs/.env"
# echo >> "srcs/.env"
# echo "# Wordpress config" >> "srcs/.env"
# echo "WORDPRESS_ADMIN_USER=admin" >> "srcs/.env"
# echo "WORDPRESS_ADMIN_PASSWORD=admin_password" >> "srcs/.env"
# echo "WORDPRESS_USER=user" >> "srcs/.env"
# echo "WORDPRESS_PASSWORD=user_password" >> "srcs/.env"
# echo "WORDPRESS_DOMAIN=danfern3.42.fr" >> "srcs/.env"
# echo "WORDPRESS_TITLE=inception" >> "srcs/.env"

print_ok ".env"
