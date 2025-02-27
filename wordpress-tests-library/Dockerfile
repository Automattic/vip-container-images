# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM busybox:stable-musl@sha256:52931c5795db81b02f89211b300630477f851870b5504d6883c7c38f99f4e692 AS build-wptl
ARG WP_GIT_REF
ADD https://github.com/WordPress/wordpress-develop.git#${WP_GIT_REF}:/tests/phpunit/includes/ /wordpress-tests-lib/includes
ADD https://github.com/WordPress/wordpress-develop.git#${WP_GIT_REF}:/tests/phpunit/data/ /wordpress-tests-lib/data
RUN \
    if [ -z "${WP_GIT_REF}" ]; then \
        SUBDIR="refs/heads/trunk"; \
    else \
        SUBDIR="refs/tags/${WP_GIT_REF}"; \
    fi && \
    wget -qO- "https://raw.githubusercontent.com/WordPress/wordpress-develop/${SUBDIR}/wp-tests-config-sample.php" | \
        sed \
            "s/youremptytestdbnamehere/wordpress_test/; s/yourusernamehere/wordpress/; s/yourpasswordhere/wordpress/; s/localhost/database/; s:dirname( __FILE__ ) . '/src/':'/wp/':" \
        > /wordpress-tests-lib/wp-tests-config.php

FROM --platform=$BUILDPLATFORM scratch
COPY --link --from=build-wptl --chown=1000:1000 /wordpress-tests-lib /wordpress-tests-lib
