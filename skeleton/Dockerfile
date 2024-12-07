FROM ghcr.io/automattic/vip-container-images/alpine:3.21.0@sha256:32cff7c1b6fe35a9f3d0c829a5a29ca80761a19ae63c15c914bf4c03fbf7df66

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]