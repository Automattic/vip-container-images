#!/bin/sh

# this script is run as root user, however we want /shared folder to be owned by www-data user in the end

if [ ! -d /shared/.git ]; then
  rsync -a --delete --delete-delay /mu-plugins/ /shared/
  chown www-data -R /shared
fi

su www-data -c /autoupdate.sh
