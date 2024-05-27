FROM ghcr.io/automattic/vip-container-images/alpine:3.20.0@sha256:ca522819065299fa631c8cfee51401de11642f1dbccd06d9cbb6ee6992caf516

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]