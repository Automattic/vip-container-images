FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:b51a674239f29a14c88c63d5e200ad91b503e4e90eb4f8e09532bc1da22f8255

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]