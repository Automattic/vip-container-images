FROM ghcr.io/automattic/vip-container-images/alpine:3.20.0@sha256:c9d85772a56acb3589335658a01d7c98827203a28274382a2206564f3e7fc8fa

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]