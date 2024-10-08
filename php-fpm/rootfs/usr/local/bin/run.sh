#!/bin/sh

if [ "enable" = "$XDEBUG" ]; then
    echo "Enabling XDebug"
    phpenmod xdebug
else
    echo "Disabling XDebug"
    phpdismod xdebug
fi

if [ -n "${LANDO_INFO}" ] && [ 'null' != "$(echo "${LANDO_INFO}" | jq -r .mailpit)" ]; then
    phpenmod mailpit
else
    phpdismod mailpit
fi

if [ -n "${ENABLE_CRON}" ]; then
    /usr/bin/cron-control-runner -fpm-url tcp://127.0.0.1:9000 -wp-cli-path /usr/local/bin/wp -wp-path /wp -prom-metrics-address :4444 &
    PID=$!
    # shellcheck disable=SC2064
    trap "kill ${PID}" EXIT INT TERM
fi

/usr/sbin/php-fpm
