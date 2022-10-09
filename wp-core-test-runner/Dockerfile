ARG CACHE_BUSTER=""
FROM ghcr.io/automattic/vip-container-images/wp-test-base:latest@sha256:100fce8ad0fce952c3dd0e05aeb94c52c3076b691a1cbcbe523242dfe375ebab

USER root
COPY install-wp-core.sh /usr/local/bin/install-wp-core

USER circleci
# Keep in sync with wp-core-test-runner.yml
RUN	\
	WORDPRESS_VERSIONS="$(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - | jq -r '[.offers[].version] | unique | map(select( . >= "5.9")) | .[]') latest"; \
	for ver in ${WORDPRESS_VERSIONS}; do /usr/local/bin/install-wp-core "${ver}"; done

USER root
COPY configure-environment.sh /usr/local/bin/configure-environment
COPY create-database.sh /usr/local/bin/create-database
COPY runner.sh /usr/local/bin/runner
ENTRYPOINT ["/usr/local/bin/runner"]

USER circleci
