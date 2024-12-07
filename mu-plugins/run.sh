#!/bin/sh

if [ ! -f /shared/.version ] || ! cmp -s /shared/.version /mu-plugins/.version; then
    rm -f /shared/.version
    rsync -a --delete-after --exclude='/.version' /mu-plugins/ /shared/
    cp /mu-plugins/.version /shared/
fi
