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

exec /usr/sbin/php-fpm82
