#!/bin/bash


cat << EOF

# Funcionamiento de Dockerfile para Nginx
# Este Dockerfile crea una imagen de Nginx basada en Alpine Linux.

# Sintaxis básica:
    # FROM <imagen_base>
    # RUN <comando_para_ejecutar>
    # COPY <origen> <destino>
    # CMD <comando_por_defecto_en_json>

# Ultima version es 3.22.2 al momento de hacerlo
# FROM debian:trixie
FROM alpine:3.19

# Al estar basado en Alpine, usamos apk para instalar nginx y openssl
# RUN apt-get update && apt-get install -y nginx
RUN apk update && apk add --no-cache nginx openssl

# Hay que crear el directorio /run/nginx para que Nginx pueda crear su archivo PID
RUN mkdir -p /run/nginx /etc/nginx/ssl

# COPY ./tools/generate-ssl.sh /generate-ssl.sh
# RUN chmod +x /generate-ssl.sh
# RUN /generate-ssl.sh

# # Copiamos el archivo de configuración personalizado y el contenido HTML
RUN mkdir -p /var/www/static
COPY ./web/index.html /var/www/static/index.html
COPY ./default.conf /etc/nginx/http.d/.
# RUN mkdir -p /run/nginx

COPY ./tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# # Exponemos el puerto 80 para HTTP
EXPOSE 443

# Comando por defecto para ejecutar Nginx en primer plano
# Ya que Nginx por defecto se ejecuta en segundo plano (daemon)
CMD ["/setup.sh"]

EOF
