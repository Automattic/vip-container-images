FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:4c3d39b993047686779ccbb41ee3fbd95dfd4305b0ba7634b99e98233e017022

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]