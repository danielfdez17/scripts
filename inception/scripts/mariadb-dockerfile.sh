#!/bin/bash


cat << EOF

FROM alpine:3.19

# Instalar MariaDB y cliente
RUN apk add --no-cache mariadb mariadb-client bash

# Crear directorios necesarios y establecer permisos
RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copiar config y script de inicialización
COPY mariadb-server.cnf /etc/my.cnf.d/.
COPY ./tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Exponer puerto de MariaDB
EXPOSE 3306

# Comando principal
ENTRYPOINT ["/setup.sh"]

EOF
