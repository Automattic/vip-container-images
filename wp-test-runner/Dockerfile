# syntax=docker/dockerfile:1.7

##############
# Base Image #
##############
FROM ubuntu:noble AS base
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
	apt-get install -y --no-install-recommends ca-certificates curl gnupg2 jq lsb-release subversion unzip wget && \
	CODENAME="$(lsb_release -sc)" && \
	echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu ${CODENAME} main" > /etc/apt/sources.list.d/php.list && \
	curl -sSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x71DAEAAB4AD4CAB6" | gpg --dearmor > /etc/apt/trusted.gpg.d/ppa-ondrej-php.gpg && \
	apt-get update && \
	apt-get -y upgrade

ENV LD_PRELOAD=/usr/lib/libeatmydata/libeatmydata.so


###################
# WordPress Image #
###################
FROM --platform=$BUILDPLATFORM base AS build-wp
RUN install -d -o ubuntu -g ubuntu -m 0777 /wordpress
COPY install-wp /usr/local/bin/

USER ubuntu
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
RUN \
	set -ex; \
	WP_VERSIONS="$(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - | jq -r '[.offers[].version] | unique | map(select( . >= "6.2")) | .[]')"; \
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
	echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/ubuntu" && \
	chmod 0440 "/etc/sudoers.d/ubuntu" && \
	echo "xdebug.mode=coverage" | tee -a /etc/php/*/mods-available/xdebug.ini && \
	update-alternatives --set php /usr/bin/php8.3 && \
	wget https://getcomposer.org/installer -qO - | php -- --install-dir=/usr/bin/ --filename=composer

ADD --chmod=0755 https://phar.phpunit.de/phpunit-9.phar /usr/local/bin/phpunit9
ADD --chmod=0755 https://phar.phpunit.de/phpunit-10.phar /usr/local/bin/phpunit10
ADD --chmod=0755 https://phar.phpunit.de/phpcov.phar /usr/local/bin/phpcov
COPY create-database configure-environment install-wp runner /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/runner"]

# Compatibility
RUN ln -s /home/ubuntu /home/circleci && install -d -m 0777 -o ubuntu -g ubuntu /home/ubuntu/project

USER ubuntu
COPY --from=build-wp --chown=ubuntu:ubuntu /home/ubuntu/.nvm /home/ubuntu/.nvm
COPY --from=build-wp --chown=ubuntu:ubuntu /wordpress /wordpress
ENV NVM_DIR=/home/ubuntu/.nvm
RUN \
	set +x && \
	. "${NVM_DIR}/nvm.sh" && \
	nvm install --lts && \
	nvm use --lts

WORKDIR /home/ubuntu/project