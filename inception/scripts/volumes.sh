#!/bin/bash

if [ ! -d ~/data/wordpress ]; then
  mkdir -p ~/data/wordpress
fi

if [ ! -d ~/data/mariadb ]; then
  mkdir -p ~/data/mariadb
fi

echo "Created necessary directories for WordPress and MariaDB data."