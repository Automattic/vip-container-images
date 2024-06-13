FROM ghcr.io/automattic/vip-container-images/alpine:3.20.0@sha256:29869c53b1bbeee09695c55b513f985fdbce4cc51871a96be45e2e78bd14bbcb

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]