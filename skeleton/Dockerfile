FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:aa1029d61e46bb10fef8e4be241643b95f63887ae432fff80b307829bc6a3045

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]