FROM ghcr.io/automattic/vip-container-images/wp-test-base:latest@sha256:e9735c7e4928358649ce132aed353410068d8e9be4c0b4e9ea087d3091e00529

USER root
COPY install-wp.sh /usr/local/bin/install-wp

USER circleci
RUN \
	WP_VERSIONS=$(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - | jq -r '[.offers[].version] | unique | map(select( . >= "5.5")) | .[]'); \
	for version in ${WP_VERSIONS} latest; do \
		install-wp "${version}" & \
	done && \
	wait

RUN install-wp nightly

USER root
COPY configure-environment.sh /usr/local/bin/configure-environment
COPY create-database.sh /usr/local/bin/create-database
COPY runner.sh /usr/local/bin/runner
ENTRYPOINT ["/usr/local/bin/runner"]

USER circleci
