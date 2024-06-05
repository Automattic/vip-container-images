FROM ghcr.io/automattic/vip-container-images/alpine:3.20.0@sha256:4c6f8b22aeeb62ce338a05affedcfa491ee46ad9dae243d2fe4d733d00bdc414

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]