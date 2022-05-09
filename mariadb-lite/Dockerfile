FROM circleci/mariadb:10.7@sha256:56d31b43f88890204cdeabcb5a0b1c3af63eea69021e152850f02cf71b305361

RUN \
    apt-get -qq update && \
    apt-get -qq install eatmydata && \
    eatmydata apt-get -qq upgrade && \
    rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD libeatmydata.so
