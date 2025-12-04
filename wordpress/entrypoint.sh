#!/bin/sh

USER_ID="${1:-1000}"
GROUP_ID="${2:-1000}"

if [ ! -f /wp/wp-content/.version ] || [ ! -f /shared/wp-content/.version ] || ! cmp -s /wp/wp-content/.version /shared/wp-content/.version; then
    /usr/bin/rsync -ac --delete --chown="${USER_ID}:${GROUP_ID}" --include=/wp-content/.version /wp/ /shared/
fi

/usr/bin/rsync -ac --delete --chown="${USER_ID}:${GROUP_ID}" /dev-tools/
