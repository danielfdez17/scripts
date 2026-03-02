
FROM alpine:3.19

# Install Nginx and OpenSSL
RUN apk update && apk add --no-cache nginx openssl

# Folder for Nginx runtime files and SSL certificates
RUN mkdir -p /run/nginx /etc/nginx/ssl

# Copy custom configuration and setup file
COPY ./conf/nginx.conf /etc/nginx/http.d/.
COPY ./tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Expose port 443 for HTTPS
EXPOSE 443

# Default command to run Nginx in the foreground
CMD ["/setup.sh"]
