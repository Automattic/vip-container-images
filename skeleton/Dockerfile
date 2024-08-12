FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:9c3f9e1e1b84ca2acd715a2c9965bea0b8459f0e3267d7612d9c1da5ed7e9e20

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]