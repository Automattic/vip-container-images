FROM ghcr.io/automattic/vip-container-images/alpine:3.20.1@sha256:b2c044e9e4114e9b8d1d5e8355ab5761914a048cf89f4e08e41cb58c299749de

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]