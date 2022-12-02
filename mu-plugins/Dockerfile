FROM ghcr.io/automattic/vip-container-images/alpine:3.17.0@sha256:755d1f3dc85bfa36a20290c6b76644c3bfee6fa8aaa975da893a45420698c209

RUN \
    apk add --no-cache git && \
    git clone --depth 1 --no-remote-submodules -b staging https://github.com/Automattic/vip-go-mu-plugins /shared && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins-ext /mu-plugins-ext && \
    cd /shared && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init --recursive --depth 1 && \
    rsync -a -r --delete --exclude-from="/mu-plugins-ext/.dockerignore" /mu-plugins-ext/* /shared && \
    rm -rf /mu-plugins-ext && \
    rm -rf /shared/tests /shared/__tests__ /shared/bin /shared/ci

COPY run.sh /run.sh

CMD ["/bin/sh", "/run.sh"]
