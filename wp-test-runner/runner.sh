#!/bin/sh

set -e

configure-environment
create-database

: "${PHP_OPTIONS:=""}"
: "${PHPUNIT_VERSION:=""}"
: "${APP_HOME:="/home/circleci/project"}"
: "${PRETEST_SCRIPT:=""}"

PHP="php ${PHP_OPTIONS}"

if [ -x "${APP_HOME}/vendor/bin/phpunit" ] && [ -z "${PHPUNIT_VERSION}" ]; then
	PHPUNIT="${APP_HOME}/vendor/bin/phpunit"
elif [ -n "${PHPUNIT_VERSION}" ] && [ -x "/usr/local/bin/phpunit${PHPUNIT_VERSION}" ]; then
	PHPUNIT="/usr/local/bin/phpunit${PHPUNIT_VERSION}"
else
	PHPUNIT=~/.composer/vendor/bin/phpunit
fi

if [ -n "${PRETEST_SCRIPT}" ] && [ -x "${PRETEST_SCRIPT}" ]; then
	"${PRETEST_SCRIPT}"
fi

echo "Running tests..."
# shellcheck disable=SC2086 # PHPUNIT_ARGS should not be quoted
${PHP} "${PHPUNIT}" ${PHPUNIT_ARGS} "$@"
