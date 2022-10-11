#!/bin/sh

set -e

: "${MYSQL_USER="wordpress"}"
: "${MYSQL_PASSWORD="wordpress"}"
: "${MYSQL_DB="wordpress_test"}"
: "${MYSQL_HOST="db"}"
: "${WP_VERSION:="latest"}"

sudo update-alternatives --set php "/usr/bin/php8.0"

if [ ! -d "/wordpress/wordpress-core-${WP_VERSION}" ]; then
	install-wp-core "${WP_VERSION}"
fi

rm -f "${HOME}/wordpress-core" || true
ln -sf "/wordpress/wordpress-core-${WP_VERSION}" "${HOME}/wordpress-core"
sed \
	"s/youremptytestdbnamehere/${MYSQL_DB}/; s/yourusernamehere/${MYSQL_USER}/; s/yourpasswordhere/${MYSQL_PASSWORD}/; s|localhost|${MYSQL_HOST}|" \
	"${HOME}/wordpress-core/wp-tests-config-sample.php" \
	> "${HOME}/wordpress-core/wp-tests-config.php"
