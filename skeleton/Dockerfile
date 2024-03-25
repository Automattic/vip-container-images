FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:c3d732e95dde5fa3b5bc9d97ade72f456b071e7cb76334b759185319fcd7e965

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]