FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:fb7292d1795e603456c144c2f910e45873c4e549d10fc817ab83b1cb9d12b52a

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]