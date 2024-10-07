FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:6075ad8c5586cb01ead468ae2d685958da0f5b9f7210b9ab9299353693782342

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]