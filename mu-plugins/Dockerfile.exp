FROM ghcr.io/automattic/vip-container-images/alpine:3.16.3@sha256:1e915c312415f9347124214ba535752d83c9a3b81622c62defc02e8a1df8176a

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

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

CMD ["/bin/sh", "/usr/local/bin/entrypoint.sh"]
