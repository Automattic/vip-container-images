#!/bin/sh

set -e

configure-environment
create-database

: "${PHP_OPTIONS:=""}"
: "${WP_MULTISITE:=""}"
: "${WP_VERSION:="latest"}"
: "${PRETEST_SCRIPT:=""}"

PHP="php ${PHP_OPTIONS}"
PHPUNIT_ARGS=

if [ "1" = "${WP_MULTISITE}" ]; then
	PHPUNIT_ARGS="-c tests/phpunit/multisite.xml"
fi

if [ "${WP_VERSION}" != "nightly" ] && [ "${WP_VERSION}" != "trunk" ]; then
	export GITHUB_EVENT_NAME=pull_request
fi

if [ -n "${PRETEST_SCRIPT}" ] && [ -x "${PRETEST_SCRIPT}" ]; then
	"${PRETEST_SCRIPT}"
fi

# shellcheck disable=SC2086
cd "${HOME}/wordpress-core/" && ${PHP} "${HOME}/wordpress-core/vendor/bin/phpunit" ${PHPUNIT_ARGS}
