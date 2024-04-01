FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:78e0a669f20be64d19dd3d097833509344f2d4b8bd1f9342f90cf151ac821986

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]