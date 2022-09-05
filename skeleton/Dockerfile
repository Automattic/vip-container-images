FROM ghcr.io/automattic/vip-container-images/alpine:3.16.2@sha256:ef724194a4da6ffd3bc50e182cbaa88c599547bf9fabf9e4a6f6d58482688e6d

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]