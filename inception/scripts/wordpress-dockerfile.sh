#!/bin/bash


cat << EOF


# Funcionamiento de Dockerfile para Wordpress
# Este Dockerfile crea una imagen de Wordpress/php-fpm basada en Alpine Linux.

# Sintaxis básica:
    # FROM <imagen_base>
    # RUN <comando_para_ejecutar>
    # COPY <origen> <destino>
    # CMD <comando_por_defecto_en_json>

# Ultima version es 3.22.2 al momento de hacerlo
FROM alpine:3.19

# Instalamos PHP y las extensiones necesarias
RUN apk update && apk add --no-cache php82 php82-phar php82-fpm php82-mysqli php82-json php82-curl php82-dom php82-mbstring php82-iconv php82-openssl php82-xml php82-zip php82-session php82-tokenizer php82-ctype php82-simplexml php82-xmlreader php82-zlib php82-gd php82-fileinfo mysql-client curl bash

RUN echo "memory_limit = 256M" >> /etc/php82/php.ini

# Copiamos el archivo de configuración personalizado de php-fpm
COPY ./www.conf /etc/php82/php-fpm.d/www.conf
COPY ./tools/script.sh /script.sh
RUN chmod +x /script.sh

# Exponemos el puerto 9000 para HTTP
EXPOSE 9000

# Comando para iniciar php-fpm en primer plano. -F evita que se ejecute como daemon.
CMD ["./script.sh"]

EOF
