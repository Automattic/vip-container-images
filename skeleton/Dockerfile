FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:5e4f9539ec5e8a65182e25c0fb66c719323670b8fe84721ebe85ae5bd3ca9877

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]