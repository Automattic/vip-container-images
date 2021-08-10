#!/bin/sh

if [ ! -d /shared/.git ]; then
  rsync -a --delete --delete-delay /mu-plugins/ /shared/
fi

exec /autoupdate.sh