#!/bin/bash


cat << EOF
#!bin/sh

# Folder where certificates will be stored
SSL_DIR="/etc/nginx/ssl"
mkdir -p $SSL_DIR

# If the certificate and key already exist, skip generation to avoid overwriting
if [ -f "\$SSL_DIR/nginx.crt" ] && [ -f "\$SSL_DIR/nginx.key" ]; then
    echo "SSL certificates already exist. Skipping generation."
    exit 0
fi

echo "Generating SSL certificate..."

# Generate a self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout \$SSL_DIR/nginx.key -out \$SSL_DIR/nginx.crt -subj "/C=ES/ST=Madrid/L=Madrid/O=42Madrid/OU=Student/CN=danfern3.42.fr"

# Set appropriate permissions for the certificate and key
chmod 644 \$SSL_DIR/nginx.crt
chmod 600 \$SSL_DIR/nginx.key

echo "SSL certificate generated successfully!"

nginx -g "daemon off;"
EOF
