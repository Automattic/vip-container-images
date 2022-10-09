FROM ghcr.io/automattic/vip-container-images/alpine:3.16.2@sha256:007a0e43847590036e3c46fdf91f5af8b2b1e735fc271709a45af511b41c0667

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]