FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:3aee703f219f7c0da46e5ff7f7bbf02ec4aa08b7e9b39de9ce6333d2731d2948

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]