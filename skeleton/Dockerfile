FROM ghcr.io/automattic/vip-container-images/alpine:3.18.4@sha256:6b50cbfe31bd2f0162c8b7924fd14bd58a7b2a07ca51d641d952deb7306762ac

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]