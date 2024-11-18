FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:e58a881e7d7786871e72817bab788a82e9f29114fc8584c1ca3448634df0012d

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]