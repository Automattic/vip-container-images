FROM ghcr.io/automattic/vip-container-images/alpine:3.18.5@sha256:2f570165292f81b6c5a2a56f5517ef097a38de113b5682d7f34f9353bba89b34

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]