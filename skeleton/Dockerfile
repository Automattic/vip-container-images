FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:2ada641f80c002a858313872ea3c0911e51f1732bb97595ee5073bb49cdbf1e3

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]