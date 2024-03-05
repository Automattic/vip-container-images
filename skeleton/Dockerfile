FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:a19e678615200ab6023130e25759747bb2420a0b6ce8aa75923756201ec1017f

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]