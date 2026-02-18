#!/bin/bash

. "$(dirname "$0")/../utils/colors.sh"

print_error "This script should receive the name of the 42 student"

inception_folder="inception"

create_inception_folder()
{
	print_info "Creating inception folder..."
	mkdir -p "$inception_folder"
}

if [ -d "$inception_folder" ]; then
	print_info "The folder '$inception_folder' already exists. Do you want to remove it? (y/n) "
	read -r response
	if [ "$response" = "y" ]; then
		rm -rf "$inception_folder"
		create_inception_folder
	else
		print_info "Aborting script execution."
		exit 1
	fi
else
	create_inception_folder
fi

# ? Variables
srcs=$inception_folder"/srcs"
requirements=$srcs"/requirements"
mariadb=$requirements"/mariadb"
nginx=$requirements"/nginx"
wordpress=$requirements"/wordpress"

print_info "Creating volumes folders..."
print_error "Uncomment this lines!"
# sudo mkdir -p /home/danfern3/data/web
# sudo mkdir -p /home/danfern3/data/mariadb
# print_ok "Volumes folders created successfully!"
print_error "Uncomment this lines!"

print_info "Creating folder structure..."
mkdir -p "$srcs"
mkdir -p "$requirements"
mkdir -p "$mariadb"
mkdir -p "$nginx"
mkdir -p "$wordpress"

sh scripts/makefile.sh > "$srcs/Makefile"

sh scripts/docker-compose.sh > "$srcs/docker-compose.yml"

mkdir -p "$wordpress/conf"
mkdir -p "$wordpress/tools"

sh scripts/wordpress-dockerfile.sh > "$wordpress/Dockerfile"
sh scripts/wordpress-conf.sh > "$wordpress/conf/www.conf"
sh scripts/wordpress-tools.sh > "$wordpress/tools/script.sh"

mkdir -p "$mariadb/conf"
mkdir -p "$mariadb/tools"

sh scripts/mariadb-dockerfile.sh > "$mariadb/Dockerfile"
sh scripts/mariadb-conf.sh > "$mariadb/conf/mariadb-server.cnf"
sh scripts/mariadb-tools.sh > "$mariadb/tools/setup.sh"


mkdir -p "$nginx/conf"
mkdir -p "$nginx/tools"

sh scripts/nginx-dockerfile.sh > "$nginx/Dockerfile"
sh scripts/nginx-conf.sh > "$nginx/conf/nginx.conf"
sh scripts/nginx-tools.sh > "$nginx/tools/setup.sh"

print_error "There is no Makefile"

print_ok "Inception folder structure created successfully!"

sh scripts/env.sh $inception_folder