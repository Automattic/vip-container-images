FROM ghcr.io/automattic/vip-container-images/alpine:3.18.4@sha256:64452e6bfb86497fa82b563e7aee80adab5201d6b51800caf64bd8c550eef46e

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]