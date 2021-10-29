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
. /helpers/log.sh

LANDO_MODULE="vip"


: ${LANDO_WEBROOT_USER:='www-data'}
: ${LANDO_WEBROOT_UID:=$(id -u $LANDO_WEBROOT_USER 2>/dev/null)}


lando_info "Making sure $LANDO_WEBROOT_USER id ('$LANDO_WEBROOT_UID') is correctly mapped to '$LANDO_HOST_UID'"

if [ "$LANDO_WEBROOT_UID" != "$LANDO_HOST_UID" ]; then
    lando_warn "User $LANDO_WEBROOT_USER is NOT correctly mapped. Will attempt to fix that."
    which useradd > /dev/null 2>&1;
    if [ $? != 0 ]; then
        lando_info "Installing shadow to support wider uid range"
        apk add --no-cache shadow > /dev/null 2>&1
    fi

    userdel "$LANDO_WEBROOT_USER" > /dev/null 2>&1
    useradd --uid "$LANDO_HOST_UID" -M -N "$LANDO_WEBROOT_USER"
    if [ $? = 0 ]; then
        lando_info "SUCCESS: user was added"
    else
        lando_error "User was not added"
    fi
fi
