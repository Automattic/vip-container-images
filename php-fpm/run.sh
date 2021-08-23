#! /bin/bash
XDEBUG_CONFIG_TEMPLATE_LOCATION=/usr/local/php/conf.d/docker-php-ext-xdebug.ini.template
XDEBUG_CONFIG_TARGET_LOCATION=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

if [ "enable" == "$XDEBUG" ]; then
    echo "Enabling XDebug"

    cp $XDEBUG_CONFIG_TEMPLATE_LOCATION $XDEBUG_CONFIG_TARGET_LOCATION
else
    echo "Disabling XDebug"

    if [ -e $XDEBUG_CONFIG_TARGET_LOCATION ]; then
        rm -f $XDEBUG_CONFIG_TARGET_LOCATION
    fi
fi


php-fpm