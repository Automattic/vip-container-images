FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:6a12dc5c6b0ad56488442120d1aac93da9f240ee1fe7f3249db0195f7d1d0c88

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]