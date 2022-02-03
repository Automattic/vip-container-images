#!/bin/sh

set -e

. configure-environment
. create-database

: "${PHP_OPTIONS:=""}"
: "${PHPUNIT_VERSION:=""}"
: "${APP_HOME:="/home/circleci/project"}"
: "${PRETEST_SCRIPT:=""}"

if [ ! -d "${APP_HOME}/vendor/yoast/phpunit-polyfills" ]; then
	WP_TESTS_PHPUNIT_POLYFILLS_PATH="$(composer config -g home)/vendor/yoast/phpunit-polyfills/phpunitpolyfills-autoload.php"
	PHP="${PHP} -d auto_prepend_file=${WP_TESTS_PHPUNIT_POLYFILLS_PATH}"
fi

if [ -n "${PRETEST_SCRIPT}" ] && [ -x "${PRETEST_SCRIPT}" ]; then
	"${PRETEST_SCRIPT}"
fi

echo "Running tests..."
# shellcheck disable=SC2086 # PHPUNIT_ARGS should not be quoted
${PHP} "${PHPUNIT}" ${PHPUNIT_ARGS} "$@"
