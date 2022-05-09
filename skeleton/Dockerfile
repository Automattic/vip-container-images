FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:81651cfe524426b5066c9670d8b816a505a605df9e1d8c3d16097026388ee402

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]