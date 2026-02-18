#!/bin/bash


cat << EOF

#!bin/sh

# Directorio donde se guardarán los certificados
SSL_DIR="/etc/nginx/ssl"
mkdir -p $SSL_DIR

# Verificar si ya existen los certificados
if [ -f "\$SSL_DIR/nginx.crt" ] && [ -f "\$SSL_DIR/nginx.key" ]; then
    echo "SSL certificates already exist. Skipping generation."
    exit 0
fi

echo "Generating SSL certificate..."

# Generar certificado autofirmado
# -x509: Crear certificado autofirmado en lugar de
# una solicitud de firma de certificado (esta forma es gratis)

# -nodes: No cifrar la clave privada (sin contraseña) sino no se podrá usar automáticamente
# -days 365: Válido por 1 año (tiempo suficiente para pruebas locales)
# -newkey rsa:2048: Crear nueva clave RSA de 2048 bits (seguridad adecuada es la mas balanceada)
# -keyout: Archivo de salida para la clave privada (.key es estándar para claves privadas)
# -out: Archivo de salida para el certificado (.crt es estándar para certificados. Es el que se instala en los navegadores de clientes)
# -subj: Información del certificado (país, estado, localidad, organización, unidad organizativa, nombre común)
# sin el, el comando pediría interactivamente esta información
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout \$SSL_DIR/nginx.key -out \$SSL_DIR/nginx.crt -subj "/C=ES/ST=Madrid/L=Madrid/O=42Madrid/OU=Student/CN=danfern3.42.fr"

# Ajustar permisos
chmod 644 \$SSL_DIR/nginx.crt
chmod 600 \$SSL_DIR/nginx.key

echo "SSL certificate generated successfully!"

EOF
