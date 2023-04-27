#!/bin/sh

if [ "enable" = "$XDEBUG" ]; then
    echo "Enabling XDebug"
    phpenmod -s fpm xdebug
    cp "$XDEBUG_CONFIG_TEMPLATE_LOCATION" "$XDEBUG_CONFIG_TARGET_LOCATION"
else
    echo "Disabling XDebug"
    phpdismod -s fpm xdebug
fi

if [ -n "${LANDO_INFO}" ] && [ 'null' != "$(echo "${LANDO_INFO}" | jq -r .mailhog)" ]; then
    phpenmod mailhog
elif [ -n "${LANDO_INFO}" ] && [ 'null' != "$(echo "${LANDO_INFO}" | jq -r .mailpit)" ]; then
    phpenmod mailpit
else
    phpdismod mailhog mailpit
fi

exec /usr/sbin/php-fpm
