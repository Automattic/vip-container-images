FROM ghcr.io/automattic/vip-container-images/alpine:3.18.4@sha256:4aabd380dadfd20355e04ba899d751a56ab7dc1506daceb0370879791babf9c3

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]