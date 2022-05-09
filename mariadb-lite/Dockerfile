FROM circleci/mariadb:10.3@sha256:6d3dea5cadaa21fdfd74cc0c0e6360a467090bae312c369c68c72c94704e54f4

RUN \
    apt-get -qq update && \
    apt-get -qq install eatmydata && \
    eatmydata apt-get -qq upgrade && \
    rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD libeatmydata.so
