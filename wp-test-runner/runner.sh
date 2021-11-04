#!/bin/sh

set -x
set -e

: "${MYSQL_USER="wordpress"}"
: "${MYSQL_PASSWORD="wordpress"}"
: "${MYSQL_DB="wordpress_test"}"
: "${MYSQL_HOST="db"}"
: "${WP_VERSION:="latest"}"
: "${PHPUNIT_VERSION:=""}"
: "${PHP_VERSION:=""}"
: "${DISABLE_XDEBUG:=""}"
: "${APP_HOME:="/home/circleci/project"}"

if [ ! -d "/wordpress/wordpress-${WP_VERSION}" ] || [ ! -d "/wordpress/wordpress-tests-lib-${WP_VERSION}" ]; then
	install-wp "${WP_VERSION}"
fi

(
	cd "/wordpress/wordpress-tests-lib-${WP_VERSION}" && \
	cp -f wp-tests-config-sample.php wp-tests-config.php && \
	sed -i "s/youremptytestdbnamehere/${MYSQL_DB}/; s/yourusernamehere/${MYSQL_USER}/; s/yourpasswordhere/${MYSQL_PASSWORD}/; s|localhost|${MYSQL_HOST}|" wp-tests-config.php && \
	sed -i "s:dirname( __FILE__ ) . '/src/':'/tmp/wordpress/':" wp-tests-config.php
)

rm -rf /tmp/wordpress /tmp/wordpress-tests-lib
ln -sf "/wordpress/wordpress-${WP_VERSION}" /tmp/wordpress
ln -sf "/wordpress/wordpress-tests-lib-${WP_VERSION}" /tmp/wordpress-tests-lib

if [ -n "${PHP_VERSION}" ] && [ -x "/usr/bin/php${PHP_VERSION}" ]; then
	sudo update-alternatives --set php "/usr/bin/php${PHP_VERSION}"
fi

if [ -n "${DISABLE_XDEBUG}" ]; then
	PHPUNIT_ARGS="-d xdebug.mode=Off"
else
	PHPUNIT_ARGS=
fi

echo "Waiting for MySQL..."
while ! nc -z "${MYSQL_HOST}" 3306; do
	sleep 1
done

mysqladmin create "${MYSQL_DB}" --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --host="${MYSQL_HOST}" || true

php -v

if [ -f "${APP_HOME}/phpunit.xml" ] || [ -f "${APP_HOME}/phpunit.xml.dist" ]; then
	if [ -x "${APP_HOME}/vendor/bin/phpunit" ] && [ -z "${PHPUNIT_VERSION}" ]; then
		PHPUNIT="${APP_HOME}/vendor/bin/phpunit"
	elif [ -n "${PHPUNIT_VERSION}" ] && [ -x "/usr/local/bin/phpunit${PHPUNIT_VERSION}" ]; then
		PHPUNIT="/usr/local/bin/phpunit${PHPUNIT_VERSION}"
	else
		PHPUNIT=~/.composer/vendor/bin/phpunit
	fi

	"${PHPUNIT}" --version
	echo "Running tests..."
	# shellcheck disable=SC2086 # PHPUNIT_ARGS should not be quoted
	"${PHPUNIT}" ${PHPUNIT_ARGS} "$@"
else
	echo "Unable to find phpunit.xml or phpunit.xml.dist in ${APP_HOME}"
	ls -lha "${APP_HOME}"
	exit 1
fi
