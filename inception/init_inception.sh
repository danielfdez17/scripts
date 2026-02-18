#!/bin/bash

# .env (no sobreescribir)
echo "DOMAIN_NAME=danfern3.42.fr" > "srcs/.env"
echo >> "srcs/.env"
echo "# Database config" >> "srcs/.env"
echo "MARIADB_DATABASE=wordpress" >> "srcs/.env"
echo "MARIADB_USER=wpuser" >> "srcs/.env"
echo "MARIADB_PASSWORD=wp_pass" >> "srcs/.env"
echo "MARIADB_ROOT_PASSWORD=root_pass" >> "srcs/.env"
echo >> "srcs/.env"
echo "# Wordpress config" >> "srcs/.env"
echo "WORDPRESS_ADMIN_USER=admin" >> "srcs/.env"
echo "WORDPRESS_ADMIN_PASSWORD=admin_password" >> "srcs/.env"
echo "WORDPRESS_USER=user" >> "srcs/.env"
echo "WORDPRESS_PASSWORD=user_password" >> "srcs/.env"
echo "WORDPRESS_DOMAIN=danfern3.42.fr" >> "srcs/.env"
echo "WORDPRESS_TITLE=inception" >> "srcs/.env"

echo "✔ .env"
