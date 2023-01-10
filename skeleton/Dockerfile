FROM ghcr.io/automattic/vip-container-images/alpine:3.17.1@sha256:fbd2cb3cd937080dd4a701d0433e7b0604260e3542a805cef815790e2f921ebf

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]