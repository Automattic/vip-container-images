FROM ghcr.io/automattic/vip-container-images/alpine:3.18.4@sha256:e818ca66bea1d187f8b3bd471a55bab64a90ad72dc58edb3ae01bb2d54f39ce6

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]