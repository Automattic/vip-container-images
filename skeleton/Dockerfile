FROM ghcr.io/automattic/vip-container-images/alpine:3.18.3@sha256:971ebed27bb94a751e26a17b8dc77b9f1b57e4a02c51b834f59025ee94eea1f4

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]