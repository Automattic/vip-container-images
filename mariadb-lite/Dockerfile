FROM circleci/mariadb:10.3

RUN \
    apt-get -qq update && \
    apt-get -qq install eatmydata && \
    eatmydata apt-get -qq upgrade && \
    rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD libeatmydata.so
