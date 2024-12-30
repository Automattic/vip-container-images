#!/bin/sh

: "${XDEBUG:=disable}"

if [ "enable" = "${XDEBUG}" ]; then
    echo "Enabling XDebug"
    phpenmod xdebug
else
    echo "Disabling XDebug"
    phpdismod xdebug
fi

# shellcheck disable=SC2312
if [ -n "${LANDO_INFO}" ] && [ 'null' != "$(echo "${LANDO_INFO}" | jq -r .mailpit)" ]; then
    phpenmod mailpit
else
    phpdismod mailpit
fi

MY_UID="$(id -u)"
FPM_OPTIONS=""

if [ "${MY_UID}" = "0" ]; then
    FPM_OPTIONS="-R"
fi

if [ -n "${ENABLE_CRON}" ]; then
    /usr/bin/cron-control-runner -fpm-url tcp://127.0.0.1:9000 -wp-cli-path /usr/local/bin/wp -wp-path /wp -prom-metrics-address :4444 &
    PID=$!
    # shellcheck disable=SC2064
    trap "kill ${PID}" EXIT INT TERM

    # shellcheck disable=SC2248
    /usr/sbin/php-fpm ${FPM_OPTIONS}
else
    # shellcheck disable=SC2248
    exec /usr/sbin/php-fpm ${FPM_OPTIONS}
fi
