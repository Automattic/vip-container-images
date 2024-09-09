FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:c42d62a4c16a177cb4d751c93b9f9050abe9335d092d0dd68d61e1fc4b12b8b5

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]