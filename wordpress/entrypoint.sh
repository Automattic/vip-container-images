#!/bin/sh

: "${LANDO_WEBROOT_USER:=www-data}"
: "${LANDO_WEBROOT_GROUP:=www-data}"

if [ -n "${LANDO_HOST_UID}" ] && [ -n "${LANDO_HOST_GID}" ]; then
    usermod -u "${LANDO_HOST_UID}" "${LANDO_WEBROOT_USER}"
    groupmod -g "${LANDO_HOST_GID}" "${LANDO_WEBROOT_GROUP}"
fi

rsync -a --chown="${LANDO_WEBROOT_USER}:${LANDO_WEBROOT_GROUP}" /wp/ /shared/
