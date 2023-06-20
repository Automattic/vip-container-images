#!/bin/sh

if [ "enable" = "$XDEBUG" ]; then
    echo "Enabling XDebug"
    phpenmod -s fpm xdebug
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

cleanup() {
    if [ -n "${ENABLE_CRON}" ]; then
        /usr/sbin/service cron stop
    fi
}

trap cleanup EXIT INT TERM

if [ -n "${ENABLE_CRON}" ]; then
    echo "*/10 * * * * /usr/bin/flock -n /tmp/wp-cron.lock /usr/local/bin/wp-cron.sh" | crontab -u www-data -
    /usr/sbin/service cron start
fi

/usr/sbin/php-fpm
