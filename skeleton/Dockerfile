FROM ghcr.io/automattic/vip-container-images/alpine:3.18.0@sha256:915576620dd16589b50da155b1bfff418a958db813e0feb4367b994e827a81b3

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]