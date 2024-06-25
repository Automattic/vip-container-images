FROM ghcr.io/automattic/vip-container-images/alpine:3.20.0@sha256:0a542e7f28185eb313c89eeed7f7abdc6baab3bcc9ac6e0709f307be6a59a954

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]