#!/bin/bash

set -e

cd /var/www/html

# Descargar WP-CLI si no existe
if [ ! -f wp-cli.phar ]; then
	echo "Downloading WP-CLI..."
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
fi

# Download WordPress and create wp-config.php if it doesn't exist
if [ ! -f wp-config.php ]; then
	echo "Downloading WordPress..."
	php wp-cli.phar core download --allow-root
	
	echo "Creating wp-config.php..."
	php wp-cli.phar config create --dbname=${MARIADB_DATABASE} --dbuser=${MARIADB_USER} --dbpass=${MARIADB_PASSWORD} --dbhost=mariadb --allow-root
	
	# Wait for MariaDB to be ready
	echo "Waiting for MariaDB to be ready..."
	until mysql -h mariadb -u ${MARIADB_USER} -p${MARIADB_PASSWORD} -e "SELECT 1" >/dev/null 2>&1; do
		echo "MariaDB is unavailable - sleeping"
		sleep 2
	done
	echo "MariaDB is ready!"
fi

# Verify if WordPress is already installed by checking for the admin user
if ! php wp-cli.phar user get ${WORDPRESS_ADMIN_USER} --allow-root 2>/dev/null; then
	echo "Installing WordPress..."
	
	# Si dice que ya está instalado pero no hay usuario, resetear la BD
	if php wp-cli.phar core is-installed --allow-root 2>/dev/null; then
		echo "WordPress tables exist but installation is incomplete. Resetting..."
		php wp-cli.phar db reset --yes --allow-root
	fi
	php wp-cli.phar core install --url=${WORDPRESS_URL} --title="${WORDPRESS_TITLE}" --admin_user=${WORDPRESS_ADMIN_USER} --admin_password=${WORDPRESS_ADMIN_PASSWORD} --admin_email=${WORDPRESS_ADMIN_USER}@example.com --skip-email --allow-root
	
	echo "WordPress installation complete!"
else
	echo "WordPress is already installed."
fi

echo "Starting PHP-FPM..."
exec php-fpm82 -F --allow-to-run-as-root
echo "PHP-FPM started successfully!"
