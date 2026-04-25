#!/bin/bash

if [ -z "$1" ]; then
	print_error "Please provide the folder name as an argument."
	exit 1
fi

inception_folder="$1"
srcs="$inception_folder/srcs"

print_info "Creating .env file with necessary environment variables for the project."

echo "# Domain name" > "$srcs/.env"
{ 
	echo "DOMAIN_NAME=danfern3.42.fr";
	echo;
	echo "# Database config"; 
	echo "MARIADB_DATABASE=wordpress"; 
	echo "MARIADB_USER=wpuser"; 
	echo "MARIADB_PASSWORD=wp_pass"; 
	echo "MARIADB_ROOT_PASSWORD=root_pass"; 
	echo; 
	echo "# Wordpress config"; 
	echo "WORDPRESS_ADMIN_USER=danfern3"; 
	echo "WORDPRESS_ADMIN_PASSWORD=superInception"; 
	echo "WORDPRESS_USER=evaluator"; 
	echo "WORDPRESS_PASSWORD=superEvaluator"; 
	echo "WORDPRESS_DOMAIN=danfern3.42.fr"; 
	echo "WORDPRESS_URL=danfern3.42.fr"; 
	echo "WORDPRESS_TITLE=inception"
} >> "$srcs/.env"

print_ok ".env"
