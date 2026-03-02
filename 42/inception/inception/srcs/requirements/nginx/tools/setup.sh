#!bin/sh

# Folder where certificates will be stored
SSL_DIR="/etc/nginx/ssl"
mkdir -p /etc/nginx/ssl

# If the certificate and key already exist, skip generation to avoid overwriting
if [ -f "/etc/nginx/ssl/nginx.crt" ] && [ -f "/etc/nginx/ssl/nginx.key" ]; then
    echo "SSL certificates already exist. Skipping generation."
else

    echo "Generating SSL certificate..."

    # Generate a self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=ES/ST=Madrid/L=Madrid/O=42Madrid/OU=Student/CN=danfern3.42.fr"

    # Set appropriate permissions for the certificate and key
    chmod 644 /etc/nginx/ssl/nginx.crt
    chmod 600 /etc/nginx/ssl/nginx.key

    echo "SSL certificate generated successfully!"

fi

nginx -g "daemon off;"
