#!/bin/sh

set -e

configure-environment

: "${PHP_OPTIONS:=""}"
: "${PHPUNIT_VERSION:=""}"
: "${APP_HOME:="/home/circleci/project"}"

PHP="php ${PHP_OPTIONS}"

if [ -f "${APP_HOME}/phpunit.xml" ] || [ -f "${APP_HOME}/phpunit.xml.dist" ]; then
	if [ -x "${APP_HOME}/vendor/bin/phpunit" ] && [ -z "${PHPUNIT_VERSION}" ]; then
		PHPUNIT="${APP_HOME}/vendor/bin/phpunit"
	elif [ -n "${PHPUNIT_VERSION}" ] && [ -x "/usr/local/bin/phpunit${PHPUNIT_VERSION}" ]; then
		PHPUNIT="/usr/local/bin/phpunit${PHPUNIT_VERSION}"
	else
		PHPUNIT=~/.composer/vendor/bin/phpunit
	fi

	echo "Running tests..."
	# shellcheck disable=SC2086 # PHPUNIT_ARGS should not be quoted
	${PHP} "${PHPUNIT}" ${PHPUNIT_ARGS} "$@"
else
	echo "Unable to find phpunit.xml or phpunit.xml.dist in ${APP_HOME}"
	ls -lha "${APP_HOME}"
	exit 1
fi
