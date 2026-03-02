FROM alpine:3.19

# Install MariaDB and client
RUN apk add --no-cache mariadb mariadb-client bash

# Create necessary directories and set permissions
RUN mkdir -p /run/mysqld /var/lib/mysql && chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copy config and initialization script
COPY ./conf/mariadb-server.cnf /etc/my.cnf.d/.
COPY ./tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Expose MariaDB port
EXPOSE 3306

# Main command
ENTRYPOINT ["/setup.sh"]
