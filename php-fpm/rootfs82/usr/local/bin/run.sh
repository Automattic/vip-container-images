#!/bin/sh

XDEBUG_CONFIG_TEMPLATE_LOCATION=/etc/php82/conf.d/xdebug.ini.template
XDEBUG_CONFIG_TARGET_LOCATION=/etc/php82/conf.d/docker-php-ext-xdebug.ini

if [ "enable" = "$XDEBUG" ]; then
    echo "Enabling XDebug"
    cp $XDEBUG_CONFIG_TEMPLATE_LOCATION $XDEBUG_CONFIG_TARGET_LOCATION
else
    echo "Disabling XDebug"
    rm -f $XDEBUG_CONFIG_TARGET_LOCATION
fi

if [ -n "${LANDO_INFO}" ] && [ 'null' != "$(echo "${LANDO_INFO}" | jq -r .mailhog)" ]; then
    echo "sendmail_path = /usr/sbin/sendmail -S $(echo "${LANDO_INFO}" | jq -r '.mailhog.internal_connection.host + ":" + .mailhog.internal_connection.port'):1025" > "${PHP_INI_DIR}/conf.d/99-mailhog.ini"
else
    rm -f "${PHP_INI_DIR}/conf.d/99-mailhog.ini"
fi

exec /usr/sbin/php-fpm82
