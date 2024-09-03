FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:e3eae9b00692dc279d7efa683c44bd7ac4b0f5abcc9d96c4ba11f03851db9d95

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]