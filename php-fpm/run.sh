#! /bin/bash
XDEBUG_CONFIG_TEMPLATE_LOCATION=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.template
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

# Kick off cron runner in a background process. Initial sleep is to help give WP time to be setup.
echo "Starting cron runner"
nohup bash -c 'sleep 60; /usr/local/bin/cron-control-runner -wp-path=/wp -wp-cli-path=/usr/local/bin/wp -get-sites-interval=120s -get-events-interval=60s' &>/tmp/cron-runner.log &

php-fpm
