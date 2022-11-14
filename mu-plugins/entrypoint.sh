#!/bin/sh

if getent passwd www-data; then
    chown -R www-data /shared
fi

exec /bin/sleep infinity
