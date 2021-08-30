FROM ghcr.io/automattic/vip-container-images/alpine:3.14.2

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    cd /clientcode && \
    rm -rf /clientcode/.git && \
    apk del build-deps

CMD ["sleep", "infinity"]