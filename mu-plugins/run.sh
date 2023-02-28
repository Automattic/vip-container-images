#!/bin/sh

if [ ! -f /shared/.version ] || ! cmp -s /shared/.version /mu-plugins/.version; then
    rm -f /shared/.version
    if getent passwd www-data; then
        CHOWN=--chown=www-data:www-data
    else
        CHOWN=
    fi

    rsync -a --delete-after --exclude='/.version' ${CHOWN} /mu-plugins/ /shared/

    if [ -n "${CHOWN}" ]; then
        install -m 0644 -o www-data -g www-data /mu-plugins/.version /shared/
    else
        cp /mu-plugins/.version /shared/
    fi
fi

exec /bin/sleep infinity
