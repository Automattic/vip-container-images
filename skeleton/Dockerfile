FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:ae68df06601d639c58eff2a5affdac18167ac23a2fc4b3778d5b18e933c47b1c

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]