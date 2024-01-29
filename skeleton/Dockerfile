FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:de90e96f3993ea1b83d12e77b1ea83937f3d01517f47dfacd02f68e4b7a825bc

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]