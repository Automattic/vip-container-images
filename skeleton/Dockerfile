FROM ghcr.io/automattic/vip-container-images/alpine:3.18.3@sha256:3ce417e785786119ded6f22268ce321153a22a9aef2ec6f0ac44773a08bfc3d4

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]