FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:65b761bde98b9d3e4b10d642b924359a58cafbd2d510a00091be0eb623143d8f

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]