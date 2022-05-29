FROM cimg/base:stable-20.04@sha256:087e0c2f4f3702c9080b726e240ec4e649eb3242cc2b453c8a49476a40bc50d1

USER root

RUN \
	export DEBIAN_FRONTEND=noninteractive; \
	echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries && \
	apt-get -qq update && apt-get -qq install eatmydata && \
	add-apt-repository -y ppa:ondrej/php && \
	eatmydata apt-get -qq upgrade && \
	eatmydata apt-get -qq install php7.4 php7.4-apcu php7.4-curl php7.4-gd php7.4-gmp php7.4-igbinary php7.4-imagick php7.4-imap php7.4-intl php7.4-mbstring php7.4-mysql php7.4-sqlite3 php7.4-xdebug php7.4-xml php7.4-xsl php7.4-zip && \
	eatmydata apt-get -qq install subversion unzip default-mysql-client && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

RUN \
	install -d -o circleci -g circleci -m 0777 /wordpress && \
	wget -q https://getcomposer.org/installer -O - | php -- --install-dir=/usr/bin/ --filename=composer

COPY install-wp-core.sh /usr/local/bin/install-wp-core
ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libeatmydata.so

USER circleci
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR /home/circleci/.nvm

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
