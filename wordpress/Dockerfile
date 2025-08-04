# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM busybox:stable-musl@sha256:74322b4716a11835c6f413fe9ffc2608ffdb8452f51cad9514a2b804908dc16e AS build-wp
ARG WP_GIT_REF
ADD https://github.com/WordPress/WordPress.git#${WP_GIT_REF} /wp
RUN rm -rf /wp/wp-content/* && install -d -m 0777 -o 1000 -g 1000 /wp/wp-content/mu-plugins
COPY extra/ /wp/

FROM --platform=$BUILDPLATFORM busybox:stable-musl@sha256:74322b4716a11835c6f413fe9ffc2608ffdb8452f51cad9514a2b804908dc16e AS build-wptl
ARG WP_TESTS_REF
ADD https://github.com/WordPress/wordpress-develop.git#${WP_TESTS_REF}:/tests/phpunit/includes/ /wordpress-tests-lib/includes
ADD https://github.com/WordPress/wordpress-develop.git#${WP_TESTS_REF}:/tests/phpunit/data/ /wordpress-tests-lib/data
RUN \
    if [ -z "${WP_TESTS_REF}" ] || [ 'trunk' = "${WP_TESTS_REF}" ]; then \
        SUBDIR="refs/heads/trunk"; \
    else \
        SUBDIR="refs/tags/${WP_TESTS_REF}"; \
    fi && \
    wget -qO- "https://raw.githubusercontent.com/WordPress/wordpress-develop/${SUBDIR}/wp-tests-config-sample.php" | \
        sed \
            "s/youremptytestdbnamehere/wordpress_test/; s/yourusernamehere/wordpress/; s/yourpasswordhere/wordpress/; s/localhost/database/; s:dirname( __FILE__ ) . '/src/':'/wp/':" \
        > /wordpress-tests-lib/wp-tests-config.php

FROM ghcr.io/automattic/vip-container-images/helpers:v1@sha256:bc2beca042ce7c47e2b737920c77248f4a6c25cc7e137bf9de6944af8a68701c AS helpers
FROM busybox:stable-musl@sha256:74322b4716a11835c6f413fe9ffc2608ffdb8452f51cad9514a2b804908dc16e
ENV WP_TESTS_DIR=/wp/wp-content/wordpress-tests-lib
COPY --from=build-wp --link /wp /wp
COPY --from=build-wptl /wordpress-tests-lib /wp/wp-content/wordpress-tests-lib
COPY --link dev-tools /dev-tools
COPY --link dev-tools /dev-tools-orig
COPY --link scripts /scripts
COPY --from=helpers /rsync /usr/bin/rsync
