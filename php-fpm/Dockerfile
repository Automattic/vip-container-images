FROM php:8.1.2-fpm-alpine3.14

RUN apk update && \
    apk add --no-cache less bash mariadb-client gd shadow && \
    apk add --no-cache --virtual build-deps $PHPIZE_DEPS build-base zlib-dev libffi-dev openssl-dev libpng libpng-dev libjpeg-turbo-dev libwebp-dev zlib-dev libxpm-dev && \
    yes '' | pecl install -f memcache && \
    docker-php-ext-install mysqli && \
    docker-php-ext-enable memcache && \
    docker-php-ext-install gd && \
    wget -O /usr/local/bin/phpunit https://phar.phpunit.de/phpunit-7.phar && \
    chmod a+x /usr/local/bin/phpunit && \
    wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod a+x /usr/local/bin/wp && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    apk del build-deps

ENV WP_CLI_CONFIG_PATH=/config/wp-cli.yaml

COPY php-fpm/wp-cli.yaml /config/wp-cli.yaml

COPY php-fpm/php.ini /usr/local/etc/php/php.ini

# move it to backup location, run-php-fpm.sh will move it to conf.d if enabled
COPY php-fpm/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.template

COPY php-fpm/run.sh /usr/local/bin/run.sh

CMD ["run.sh"]
