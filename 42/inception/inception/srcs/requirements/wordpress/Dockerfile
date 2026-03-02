FROM alpine:3.19

# Install PHP and necessary extensions
RUN apk update && apk add --no-cache php82 php82-phar php82-fpm php82-mysqli php82-json php82-curl php82-dom php82-mbstring php82-iconv php82-openssl php82-xml php82-zip php82-session php82-tokenizer php82-ctype php82-simplexml php82-xmlreader php82-zlib php82-gd php82-fileinfo mysql-client curl bash

RUN echo "memory_limit = 256M" >> /etc/php82/php.ini

# Copy custom php-fpm configuration
COPY ./conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY ./tools/script.sh /script.sh
RUN chmod +x /script.sh

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Main command to start PHP-FPM in the foreground. -F prevents it from running as a daemon.
CMD ["./script.sh"]
