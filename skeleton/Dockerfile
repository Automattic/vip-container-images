FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:a82179d7c8b607606478753d1f46a41ca55b06722b8f7e4a4a83b1473a47e55e

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]