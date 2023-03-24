FROM ghcr.io/automattic/vip-container-images/alpine:3.17.2@sha256:d0d035a71e27df5abee64bb9254632bb63a6dd3e03dbc16bcaca680519d607bd

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]