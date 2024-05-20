FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:6efe2c01373703664a6f687697965e85c1a0c0c645b50e24ccb026e74c04690e

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]