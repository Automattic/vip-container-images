FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:2532a75a8ce1691b51ff84fcfd840bbe98bd09dbf7a0b58cad77f16294ffe202

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]