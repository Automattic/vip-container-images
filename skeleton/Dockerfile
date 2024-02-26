FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:f2e3b4ccee503ab3b9c345eb99f3b2a89867a970e1639b1a9ee86060350d9c0d

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]