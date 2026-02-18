#!/bin/bash

# todo: this files must be in the VM once the project has been closed

# .env (no sobreescribir)
echo "DOMAIN_NAME=danfern3.42.fr" > "srcs/.env"
echo >> "srcs/.env"
echo "# Certificate config" >> "srcs/.env"
echo "CERT_PATH=/etc/ssl/certs" >> "srcs/.env"
echo "CERT_KEY=nginx-autosigned.key" >> "srcs/.env"
echo "CERT=nginx-autosigned.crt" >> "srcs/.env"
echo >> "srcs/.env"
echo "# Database config" >> "srcs/.env"
echo "MYSQL_DATABASE=wordpress" >> "srcs/.env"
echo "MYSQL_USER=wpuser" >> "srcs/.env"
echo "MYSQL_PASSWORD=wp_pass" >> "srcs/.env"
echo "MYSQL_ROOT_PASSWORD=root_pass" >> "srcs/.env"
echo >> "srcs/.env"
echo "# Wordpress config" >> "srcs/.env"
echo "WP_ADMIN_USER=admin" >> "srcs/.env"
echo "WP_ADMIN_PASSWORD=admin_password" >> "srcs/.env"
echo "WP_USER=user" >> "srcs/.env"
echo "WP_PASSWORD=user_password" >> "srcs/.env"
echo "WP_DOMAIN=danfern3.42.fr" >> "srcs/.env"

echo "Created .env file with necessary environment variables for the project."
