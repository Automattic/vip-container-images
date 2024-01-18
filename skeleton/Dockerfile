FROM ghcr.io/automattic/vip-container-images/alpine:3.19.0@sha256:bbf7425566145062e41112a846d8f29e29e5c46dad2f7624baad877cd8a4b201

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]