FROM ghcr.io/automattic/vip-container-images/alpine:3.17.3@sha256:062a1ec3e5d1d7c471add8bb689ccd26a3d6a734c802bbbc37d8f456ddb27b40

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]