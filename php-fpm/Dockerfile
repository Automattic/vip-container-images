FROM php:8.1.3-fpm-alpine3.14

RUN apk add --no-cache less bash mariadb-client \
    # memcache
    zlib \ 
    # ssh2
    libssh2 \
    # gmagick
    ghostscript-fonts graphicsmagick libgomp \
    # gd
    freetype libjpeg-turbo libpng libwebp libxpm \
    # gmp
    gmp \
    # intl
    icu-libs \
    # mcrypt
    libmcrypt \
    # soap
    libxml2 \
    # zip
    libzip

RUN \
    apk add --no-cache --virtual build-deps $PHPIZE_DEPS build-base openssl-dev zlib-dev \
        # mcrypt
        libmcrypt-dev \
        # ssh2
        libssh2-dev \
        # gmagick
        graphicsmagick-dev libtool \
        # gd
        freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev libxpm-dev \
        # gmp
        gmp-dev \
        # intl
        icu-dev \
        # soap
        libxml2-dev \
        # zip
        libzip-dev && \
    pecl channel-update pecl.php.net && \
    yes '' | pecl install -f memcache && \
    pecl install apcu && \
    pecl install mcrypt && \
    pecl install timezonedb && \
    pecl install ssh2-1.3.1 && \
    pecl install gmagick-2.0.6RC1 && \
    pecl install xdebug && \
    docker-php-ext-install -j$(nproc) bcmath calendar exif gd gmp intl mysqli pcntl shmop soap sockets sysvsem sysvshm zip && \
    docker-php-ext-enable apcu gmagick mcrypt memcache ssh2 timezonedb xdebug opcache && \
    docker-php-source delete && \
    apk del build-deps && \
    rm -rf /tmp/pear ~/.pearrc

RUN \
    wget -O /usr/local/bin/phpunit https://phar.phpunit.de/phpunit-7.phar && chmod a+x /usr/local/bin/phpunit && \
    wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod a+x /usr/local/bin/wp

ENV WP_CLI_CONFIG_PATH=/config/wp-cli.yaml

COPY wp-cli.yaml /config/wp-cli.yaml

COPY php.ini /usr/local/etc/php/php.ini

# move it to backup location, run-php-fpm.sh will move it to conf.d if enabled
COPY xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.template

COPY run.sh /usr/local/bin/run.sh

CMD ["run.sh"]
