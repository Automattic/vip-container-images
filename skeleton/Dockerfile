FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:493b533533848064508cc2cb03ac4e287eae96ff32cf7b3d34742b70a8efd468

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]