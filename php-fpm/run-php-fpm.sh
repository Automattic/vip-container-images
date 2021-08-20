#! /bin/bash
XDEBUG_CONFIG_LOCATION=/usr/local/php/docker-php-ext-xdebug.ini
XDEBUG_CONFIG_TARGET_LOCATION=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

if [ "enable" == "$XDEBUG" ]; then
    echo "Enabling XDebug"

    cp $XDEBUG_CONFIG_LOCATION $XDEBUG_CONFIG_TARGET_LOCATION
else
    echo "Disabling XDebug"

    if [ -e $XDEBUG_CONFIG_TARGET_LOCATION ]; then
        rm -f $XDEBUG_CONFIG_TARGET_LOCATION
    fi
fi


php-fpm