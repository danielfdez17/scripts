#!/bin/bash


cat << EOF

#!/bin/sh

set -e

mkdir -p /var/lib/mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql

    # Empieza el servicio de MariaDB en segundo plano temporalmente
    # para ejecutar comandos de configuración inicial
    mysqld_safe --nowatch &

    # Espera a que el servidor esté listo
    until mariadb-admin ping --silent; do
        echo "Waiting for MariaDB server to start..."
        sleep 1
    done

    echo "Setting root password and creating database..."

    # Se configura la contraseña de root y se crea la base de datos
    mariadb -u root <<EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
        CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

        CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};
        CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    # Detiene el servidor MariaDB temporalmente iniciado
    mysqladmin -u root -p${MARIADB_ROOT_PASSWORD} shutdown
    echo "MariaDB initialization complete."
fi

echo "Starting MariaDB server..."
exec mysqld_safe

EOF
