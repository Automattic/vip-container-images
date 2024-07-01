FROM ghcr.io/automattic/vip-container-images/alpine:3.20.1@sha256:2959058d3f7a7765fd6676b154e9def4dfa16c6b1daa0caad98eebbdf052d2bf

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]