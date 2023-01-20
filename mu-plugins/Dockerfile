FROM ghcr.io/automattic/vip-container-images/alpine:3.17.1@sha256:fbd2cb3cd937080dd4a701d0433e7b0604260e3542a805cef815790e2f921ebf

RUN \
    apk add --no-cache git shadow && \
    git clone --depth 1 --no-remote-submodules -b staging https://github.com/Automattic/vip-go-mu-plugins /shared && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins-ext /mu-plugins-ext && \
    cd /shared && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init --recursive --depth 1 && \
    rsync -a -r --delete --exclude-from="/mu-plugins-ext/.dockerignore" /mu-plugins-ext/* /shared && \
    rm -rf /mu-plugins-ext && \
    rm -rf /shared/tests /shared/__tests__ /shared/bin /shared/ci && \
    gitsha=$(git rev-parse --short HEAD) && gitdate=$(git show -s --format=%cs "$gitsha") && date=$(date -d "$gitdate" '+%Y%m%d') && echo "{ \"tag\": \"staging\", \"stack_version\": \"${date}-${gitsha}\" }" > "/shared/.version"

COPY run.sh /run.sh

CMD ["/bin/sh", "/run.sh"]
