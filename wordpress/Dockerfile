# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM scratch AS build-wp
ARG WP_GIT_REF
ADD https://github.com/WordPress/WordPress.git#${WP_GIT_REF} /wp
COPY extra/ /wp/

FROM alpine:3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c AS build-wptl
ARG WP_GIT_REF
RUN \
    apk add --no-cache curl subversion && \
    if [ -z "${WP_GIT_REF}" ]; then \
        TESTS_TAG=trunk; \
    else \
        TESTS_TAG="tags/${WP_GIT_REF}"; \
    fi && \
    svn co --quiet --ignore-externals "https://develop.svn.wordpress.org/${TESTS_TAG}/tests/phpunit/includes/" /wordpress-tests-lib/includes && \
    svn co --quiet --ignore-externals "https://develop.svn.wordpress.org/${TESTS_TAG}/tests/phpunit/data/"     /wordpress-tests-lib/data && \
    curl -sL "https://develop.svn.wordpress.org/${TESTS_TAG}/wp-tests-config-sample.php" | \
        sed \
            "s/youremptytestdbnamehere/wordpress_test/; s/yourusernamehere/wordpress/; s/yourpasswordhere/wordpress/; s/localhost/database/; s:dirname( __FILE__ ) . '/src/':'/wp/':" \
        > /wordpress-tests-lib/wp-tests-config.php

FROM ghcr.io/automattic/vip-container-images/helpers:v1@sha256:bc2beca042ce7c47e2b737920c77248f4a6c25cc7e137bf9de6944af8a68701c AS helpers
FROM busybox:stable-musl@sha256:52931c5795db81b02f89211b300630477f851870b5504d6883c7c38f99f4e692
ENV WP_TESTS_DIR=/wp/wp-content/wordpress-tests-lib
COPY --from=build-wp --link /wp /wp
COPY --from=build-wptl /wordpress-tests-lib /wp/wp-content/wordpress-tests-lib
COPY --link dev-tools /dev-tools
COPY --link dev-tools /dev-tools-orig
COPY --link scripts /scripts
COPY --from=helpers /rsync /usr/bin/rsync
