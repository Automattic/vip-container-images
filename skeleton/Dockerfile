FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:a41a67d60109e556da61a85aa261313cd91d6676b139750496b9eb5d4fb87db8

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]