FROM ghcr.io/automattic/vip-container-images/alpine:3.19.0@sha256:ba68ecabb1fbe577d6b5fdf86c37ac62387d7325ec7aafbe15b3f0e17905b484

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]