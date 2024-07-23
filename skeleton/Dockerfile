FROM ghcr.io/automattic/vip-container-images/alpine:3.20.1@sha256:985d82836b4437d7abe359e1c368a31f3f99c52e704dfe3e13a2e3bd1b050bf7

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]