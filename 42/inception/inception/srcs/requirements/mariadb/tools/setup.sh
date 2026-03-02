#!/bin/bash

set -e

mkdir -p /var/lib/mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

if [ ! -d /var/lib/mysql/mysql ]; then
	echo "Initializing MariaDB data directory..."
	mysql_install_db --user=mysql --ldata=/var/lib/mysql

	# Starts the MariaDB service in the background temporarily to run initial configuration commands
	mysqld_safe --nowatch &

	# Waits for the MariaDB server to start
	until mariadb-admin ping --silent; do
		echo "Waiting for MariaDB server to start..."
		sleep 1
	done

	echo "Setting root password and creating database..."

	# Setting root password and creating database...
	mariadb -u root <<EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
		CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
		GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

		CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
		CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
		GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
		FLUSH PRIVILEGES;
EOSQL

	# Stops the temporarily started MariaDB server
	mysqladmin -u root -p${MARIADB_ROOT_PASSWORD} shutdown
	echo "MariaDB initialization complete."
fi

echo "Starting MariaDB server..."
exec mysqld_safe
