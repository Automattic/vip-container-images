FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:8e5863007aca82e8c7094c8cc7283a0b70aff6e6842f31e90c6f1b07e14444ff

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]