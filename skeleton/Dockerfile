FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:1d6b6971e26c7516a711b460fe990ddbadf3efa1a4fb5ea73626a1416e58c3d7

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]