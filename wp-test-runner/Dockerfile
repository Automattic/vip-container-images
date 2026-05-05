# syntax=docker/dockerfile:1.7

##############
# Base Image #
##############
FROM debian:bookworm@sha256:8a8cd02c5912770b4980228a54d4aff9e4f986f1eb2525d2d371dec5232cefcc AS base
RUN \
	rm -f /etc/apt/apt.conf.d/docker-clean && \
	echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache && \
	echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
	export DEBIAN_FRONTEND=noninteractive; \
	apt-get update && \
	apt-get -y install eatmydata && \
	mkdir -p /usr/lib/libeatmydata && ln -s -t /usr/lib/libeatmydata/ /usr/lib/$(uname -m)-linux-gnu/libeatmydata.so* && \
	export LD_PRELOAD=/usr/lib/libeatmydata/libeatmydata.so && \
	apt-get install -y --no-install-recommends ca-certificates curl jq lsb-release subversion unzip wget && \
	curl -SLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb && \
	echo '7511384559c9ddf1d5ce5f60be429ae9d4e7d01d9480d6f1b7a30c0810cf8b60  /tmp/debsuryorg-archive-keyring.deb' | sha256sum -c - && \
	dpkg -i /tmp/debsuryorg-archive-keyring.deb && \
	rm -f /tmp/debsuryorg-archive-keyring.deb && \
	CODENAME="$(lsb_release -sc)" && \
	echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ ${CODENAME} main" > /etc/apt/sources.list.d/php.list && \
	apt-get update && \
	apt-get -y upgrade && \
	useradd -m -s /bin/bash debian

ENV LD_PRELOAD=/usr/lib/libeatmydata/libeatmydata.so


###################
# WordPress Image #
###################
FROM --platform=$BUILDPLATFORM base AS build-wp
RUN install -d -o debian -g debian -m 0777 /wordpress
COPY install-wp /usr/local/bin/

USER debian
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
RUN \
	set -ex; \
	WP_VERSIONS="$(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - | jq -r '[.offers[].version] | unique | map(select( . >= "6.4")) | .[]')"; \
	for version in ${WP_VERSIONS} latest; do \
		install-wp "${version}"; \
	done

ARG CACHE_BUST=1
RUN echo "${CACHE_BUST}"; install-wp nightly

###############
# Final Image #
###############
FROM base
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
	export DEBIAN_FRONTEND=noninteractive; \
	apt-get update && \
	apt-get -y install \
		default-mysql-client netcat-openbsd sudo \
		php8.2-cli php8.2-apcu php8.2-curl php8.2-gd php8.2-gmp php8.2-igbinary php8.2-imagick php8.2-imap php8.2-intl php8.2-mbstring php8.2-mysql php8.2-sqlite3 php8.2-xdebug php8.2-xml php8.2-zip php8.2-memcache php8.2-memcached \
		php8.3-cli php8.3-apcu php8.3-curl php8.3-gd php8.3-gmp php8.3-igbinary php8.3-imagick php8.3-imap php8.3-intl php8.3-mbstring php8.3-mysql php8.3-sqlite3 php8.3-xdebug php8.3-xml php8.3-zip php8.3-memcache php8.3-memcached \
		php8.4-cli php8.4-apcu php8.4-curl php8.4-gd php8.4-gmp php8.4-igbinary php8.4-imagick php8.4-imap php8.4-intl php8.4-mbstring php8.4-mysql php8.4-sqlite3 php8.4-xdebug php8.4-xml php8.4-zip php8.4-memcache php8.4-memcached \
		php8.5-cli php8.5-apcu php8.5-curl php8.5-gd php8.5-gmp php8.5-igbinary php8.5-imagick php8.5-imap php8.5-intl php8.5-mbstring php8.5-mysql php8.5-sqlite3 php8.5-xdebug php8.5-xml php8.5-zip                 php8.5-memcached && \
	echo "debian ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/debian" && \
	chmod 0440 "/etc/sudoers.d/debian" && \
	echo "xdebug.mode=coverage" | tee -a /etc/php/*/mods-available/xdebug.ini && \
	update-alternatives --set php /usr/bin/php8.3 && \
	wget https://getcomposer.org/installer -qO - | php -- --install-dir=/usr/bin/ --filename=composer

ADD --chmod=0755 https://phar.phpunit.de/phpunit-9.phar /usr/local/bin/phpunit9
ADD --chmod=0755 https://phar.phpunit.de/phpunit-10.phar /usr/local/bin/phpunit10
ADD --chmod=0755 https://phar.phpunit.de/phpcov.phar /usr/local/bin/phpcov
COPY create-database configure-environment install-wp runner /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/runner"]

# Compatibility
RUN ln -s /home/debian /home/circleci && install -d -m 0777 -o debian -g debian /home/debian/project

USER debian
COPY --from=build-wp --chown=debian:debian /home/debian/.nvm /home/debian/.nvm
COPY --from=build-wp --chown=debian:debian /wordpress /wordpress
ENV NVM_DIR=/home/debian/.nvm
RUN \
	set +x && \
	. "${NVM_DIR}/nvm.sh" && \
	nvm install --lts && \
	nvm use --lts

WORKDIR /home/debian/project
