FROM ghcr.io/automattic/vip-container-images/alpine:3.18.2@sha256:367c1c2028f27954eee67c4ce681459edb240044561848d013e079ad9cce6cff

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]