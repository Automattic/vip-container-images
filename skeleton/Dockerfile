FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:42ee5e50414b7c636fa5ee8b0d1c6b0219bb413285e4110178b16416711f52c9

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]