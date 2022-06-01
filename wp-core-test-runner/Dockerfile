FROM ghcr.io/automattic/vip-container-images/wp-test-base:latest@sha256:215d38c840e69bffa9c4ada949032333d0bdec77d68d334da1acf9a4c7f82c3a

USER root
COPY install-wp-core.sh /usr/local/bin/install-wp-core

USER circleci
RUN \
	for version in $(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - | jq -r '[.offers[].version] | unique | map(select( . >= "5.5")) | .[]') latest; do \
		DOCKER_BUILD=1 install-wp-core "${version}"; \
	done

USER root
COPY configure-environment.sh /usr/local/bin/configure-environment
COPY create-database.sh /usr/local/bin/create-database
COPY runner.sh /usr/local/bin/runner
ENTRYPOINT ["/usr/local/bin/runner"]

USER circleci
