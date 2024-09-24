FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:06d5fe56e625629378a82cac0ee7f7976013dea8cc86b30158742f321f89f884

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]