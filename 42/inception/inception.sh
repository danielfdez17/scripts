#!/bin/bash

main_warning_msg="This script should receive the name of the 42 student"
print_error "$main_warning_msg" || echo "$main_warning_msg"

inception_folder="inception"

create_inception_folder()
{
	rm -rf "$inception_folder"
	info_msg="Creating inception folder..."
	print_info "$info_msg" || echo "$info_msg"
	mkdir -p "$inception_folder"
}

if [ -d "$inception_folder" ]; then
	existing_folder_msg="The folder '$inception_folder' already exists. Do you want to remove it? (y/n) "
	print_warning "$existing_folder_msg" || echo "$existing_folder_msg"
	read -r response
	if [ "$response" = "y" ]; then
		rm -rf "$inception_folder"
		create_inception_folder
	else
		abort_msg="Aborting script execution."
		print_info "$abort_msg" || echo "$abort_msg"
		exit 1
	fi
else
	create_inception_folder
fi

create_inception_folder
recreation_msg="The folder '$inception_folder' already exists. It will be removed and recreated."
print_warning "$recreation_msg" || echo "$recreation_msg"
# ? Variables
srcs=$inception_folder"/srcs"
requirements=$srcs"/requirements"
mariadb=$requirements"/mariadb"
nginx=$requirements"/nginx"
wordpress=$requirements"/wordpress"

# print_todo "Creating volumes folders..." || echo "Creating volumes folders..."
# print_todo "Uncomment this lines!" || echo "Uncomment this lines!"
# sudo mkdir -p /home/danfern3/data/web
# sudo mkdir -p /home/danfern3/data/mariadb
# print_ok "Volumes folders created successfully!" || echo "Volumes folders created successfully!"
# print_todo "Uncomment this lines!" || echo "Uncomment this lines!"


creating_folders_msg="Creating folder structure..."
print_info "$creating_folders_msg" || echo "$creating_folders_msg"
mkdir -p "$srcs"
mkdir -p "$requirements"
mkdir -p "$mariadb"
mkdir -p "$nginx"
mkdir -p "$wordpress"

sh scripts/makefile.sh > "$inception_folder/Makefile"

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

folder_structure_msg="Inception folder structure and files created successfully!"
print_ok "$folder_structure_msg" || echo "$folder_structure_msg"

sh scripts/env.sh $inception_folder

build_containers_msg="Build Docker images and start containers"
print_todo "$build_containers_msg" || echo "$build_containers_msg"

error_with_inception_folder_msg="Failed to enter inception folder"
cd $inception_folder || { print_error "$error_with_inception_folder_msg" || echo "$error_with_inception_folder_msg"; exit 1; }
# make all