FROM alpine:3.19.0@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48 AS build
RUN apk add --no-cache php81-dev php81-pear php81-openssl gcc make libc-dev graphicsmagick-dev libtool subversion
RUN pecl channel-update pecl.php.net
RUN pecl install channel://pecl.php.net/gmagick-2.0.6RC1 < /dev/null
RUN \
    install -d -D /usr/share/webapps/photon && \
    svn co https://code.svn.wordpress.org/photon/ /usr/share/webapps/photon && \
    rm -rf /usr/share/webapps/photon/.svn /usr/share/webapps/photon/tests

FROM alpine:3.19.0@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48
RUN \
    apk upgrade --no-cache && \
    apk add --no-cache \
        php81 php81-fpm php81-curl php81-gd php81-opcache php81-openssl graphicsmagick libgomp  \
        optipng pngquant libwebp-tools jpegoptim libjpeg-turbo-utils pngcrush && \
    ln -s /usr/sbin/php-fpm81 /usr/sbin/php-fpm

# These packages are required to download composer, install PHPUnit and run tests
# RUN apk add --no-cache php81-dom php81-fileinfo php81-mbstring php81-phar php81-pdo php81-tokenizer php81-xml php81-xmlwriter

COPY rootfs /
COPY --from=build /usr/lib/php81/modules/gmagick.so /usr/lib/php81/modules/
COPY --from=build /usr/share/webapps/photon /usr/share/webapps/photon

RUN \
    ln -s /etc/photon/config.php /usr/share/webapps/photon/config.php && \
    install -d -D -m 0755 -o nobody -g nobody /usr/share/webapps/photon/uploads

VOLUME ["/usr/share/webapps/photon/uploads"]
CMD ["/usr/sbin/php-fpm"]
