#!/bin/sh

########################
# The aim of this script is to map the www-data user to the UID of the current user starting dev-env.
# This is critical for some containers that map their files to host or to each other and want to be able to
# not only read but also write to that filesystem.
#
# Also when deleting the environment we need all those mapped files to the host system to be deletable by current user
#
# Lando already comes with a script that aims to do just that.
# https://github.com/lando/cli/blob/main/plugins/lando-core/scripts/user-perms.sh
#
# However that script is general for all posible container types and fails in some specific cases to our setup.
# This script is meant to run after lando, and if it detects lando failing will attempt to fix the issue.
########################

# Source log helper
# shellcheck source=/dev/null
. /helpers/log.sh

# shellcheck disable=SC2034
LANDO_MODULE="vip"


: "${LANDO_WEBROOT_USER:='www-data'}"
: "${LANDO_WEBROOT_GROUP:='www-data'}"
: "${LANDO_WEBROOT_UID:=$(id -u $LANDO_WEBROOT_USER 2>/dev/null)}"


lando_info "Making sure $LANDO_WEBROOT_USER id ('$LANDO_WEBROOT_UID') is correctly mapped to '$LANDO_HOST_UID'"

if [ "$LANDO_WEBROOT_UID" != "$LANDO_HOST_UID" ]; then
    lando_warn "User $LANDO_WEBROOT_USER is NOT correctly mapped. Will attempt to fix that."
    if ! which useradd > /dev/null 2>&1; then
        lando_info "Installing shadow to support wider uid range"
        apk add --no-cache shadow > /dev/null 2>&1
    fi

    userdel "$LANDO_WEBROOT_USER" > /dev/null 2>&1

    lando_info "Making sure group $LANDO_WEBROOT_GROUP exists"

    if ! grep -q "$LANDO_WEBROOT_GROUP" /etc/group; then
        lando_warn "Group $LANDO_WEBROOT_GROUP doesn't exist. Will attempt to create it."
        if groupadd "$LANDO_WEBROOT_GROUP"; then
            lando_info "SUCCESS: group added"
        else
            lando_error "Group was not added"
            exit 1;
        fi
    fi

    if useradd --uid "$LANDO_HOST_UID" -M -N -G "$LANDO_WEBROOT_GROUP" "$LANDO_WEBROOT_USER"; then
        lando_info "SUCCESS: user was added"
    else
        lando_error "User was not added"
        exit 1;
    fi

    if [ -d "/home/$LANDO_WEBROOT_USER" ]; then
        lando_info "Making $LANDO_WEBROOT_USER owner of /home/$LANDO_WEBROOT_USER"
        chown -R "$LANDO_WEBROOT_USER" "/home/$LANDO_WEBROOT_USER"
    fi
fi
