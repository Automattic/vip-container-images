FROM alpine:3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c AS build
RUN apk add --no-cache php82-dev php82-pear php82-openssl gcc make libc-dev graphicsmagick-dev libtool subversion
RUN pecl82 channel-update pecl.php.net
RUN pecl82 install channel://pecl.php.net/gmagick-2.0.6RC1 < /dev/null
RUN \
    install -d -D /usr/share/webapps/photon && \
    svn co https://code.svn.wordpress.org/photon/ /usr/share/webapps/photon -r645 && \
    rm -rf /usr/share/webapps/photon/.svn /usr/share/webapps/photon/tests

FROM alpine:3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c
RUN \
    apk upgrade --no-cache && \
    apk add --no-cache \
        php82 php82-fpm php82-curl php82-gd php82-opcache php82-openssl graphicsmagick libgomp  \
        optipng pngquant libwebp-tools jpegoptim libjpeg-turbo-utils pngcrush && \
    ln -s /usr/sbin/php-fpm82 /usr/sbin/php-fpm

# These packages are required to download composer, install PHPUnit and run tests
# RUN apk add --no-cache php82-dom php82-fileinfo php82-mbstring php82-phar php82-pdo php82-tokenizer php82-xml php82-xmlwriter

COPY rootfs /
COPY --from=build /usr/lib/php82/modules/gmagick.so /usr/lib/php82/modules/
COPY --from=build /usr/share/webapps/photon /usr/share/webapps/photon

RUN \
    ln -s /etc/photon/config.php /usr/share/webapps/photon/config.php && \
    install -d -D -m 0755 -o nobody -g nobody /usr/share/webapps/photon/uploads

VOLUME ["/usr/share/webapps/photon/uploads"]
CMD ["/usr/sbin/php-fpm"]
