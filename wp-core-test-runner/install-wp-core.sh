#!/bin/sh

set -e

download_wp_core() {
	VERSION="$1"
	if [ "${VERSION}" = "nightly" ] || [ "${VERSION}" = "trunk" ]; then
		TESTS_TAG="trunk"
	elif [ "${VERSION}" = "latest" ]; then
		VERSIONS=$(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - )
		LATEST=$(echo "${VERSIONS}" | jq -r '.offers | map(select( .response == "upgrade")) | .[0].version')
		if [ -z "${LATEST}" ]; then
			echo "Unable to detect the latest WP version"
			exit 1
		fi
		TESTS_TAG="tags/${LATEST}"
	else
		TESTS_TAG="tags/${VERSION}"
	fi

	if [ ! -d "/wordpress/wordpress-core-${VERSION}" ]; then
		mkdir -p "/wordpress/wordpress-core-${VERSION}"
		svn co --quiet --ignore-externals "https://develop.svn.wordpress.org/${TESTS_TAG}" "/wordpress/wordpress-core-${VERSION}"
		(
			cd "/wordpress/wordpress-core-${VERSION}" && \
			composer install -n && \
			nvm install && \
			nvm use && \
			npm ci && \
			npm run build
		)
	else
		echo "Skipping WordPress download"
	fi
}

# shellcheck disable=SC1091
[ -f "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"
download_wp_core "${1:-latest}"
