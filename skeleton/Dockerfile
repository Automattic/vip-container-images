FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:7f0b3ab3d6bdbe969e654b62b8f9c65bfc976d9b6778c18303415220e15944e6

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]