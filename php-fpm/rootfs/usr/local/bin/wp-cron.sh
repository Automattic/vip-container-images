#!/bin/sh

export WP_CLI_CONFIG_PATH=/config/wp-cli.yaml
PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if ! wp core is-installed; then
    exit 0;
fi

if wp core is-installed --network; then
    urls="$(wp site list --field=url)"
    for url in $urls; do
        wp --url="${url}" cron event run --due-now
    done
else
    wp cron event run --due-now
fi

exit 0
