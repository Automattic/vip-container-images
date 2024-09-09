FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:69689b7134f1559bae811cdf06829b55410c7d389af8913fbb041518c3ef0b12

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]