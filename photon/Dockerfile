FROM alpine:3.23.0@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375 AS build
RUN apk add --no-cache php83-dev php83-pear php83-openssl gcc make libc-dev graphicsmagick-dev libtool subversion
RUN pecl83 channel-update pecl.php.net
RUN pecl83 install channel://pecl.php.net/gmagick-2.0.6RC1 < /dev/null
RUN \
    install -d -D /usr/share/webapps/photon && \
    svn co https://code.svn.wordpress.org/photon/ /usr/share/webapps/photon -r645 && \
    rm -rf /usr/share/webapps/photon/.svn /usr/share/webapps/photon/tests

FROM alpine:3.23.0@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375
RUN \
    apk upgrade --no-cache && \
    apk add --no-cache \
        php83 php83-fpm php83-curl php83-gd php83-opcache php83-openssl graphicsmagick libgomp  \
        optipng pngquant libwebp-tools jpegoptim libjpeg-turbo-utils pngcrush && \
    ln -s /usr/sbin/php-fpm83 /usr/sbin/php-fpm

# These packages are required to download composer, install PHPUnit and run tests
# RUN apk add --no-cache php83-dom php83-fileinfo php83-mbstring php83-phar php83-pdo php83-tokenizer php83-xml php83-xmlwriter

COPY rootfs /
COPY --from=build /usr/lib/php83/modules/gmagick.so /usr/lib/php83/modules/
COPY --from=build /usr/share/webapps/photon /usr/share/webapps/photon

RUN \
    ln -s /etc/photon/config.php /usr/share/webapps/photon/config.php && \
    install -d -D -m 0755 -o nobody -g nobody /usr/share/webapps/photon/uploads

VOLUME ["/usr/share/webapps/photon/uploads"]
CMD ["/usr/sbin/php-fpm"]
