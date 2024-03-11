FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:d6d5e7c5c1fc1ecc896896451013911b80855342ad9494713761c3665423b518

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]