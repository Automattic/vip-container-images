FROM ghcr.io/automattic/vip-container-images/alpine:3.19.0@sha256:1a3f8755404f7f8dd05ac461f6026dd442b383400cf676888d8ba7ff0bcfa682

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]