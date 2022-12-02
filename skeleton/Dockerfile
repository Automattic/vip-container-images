FROM ghcr.io/automattic/vip-container-images/alpine:3.17.0@sha256:755d1f3dc85bfa36a20290c6b76644c3bfee6fa8aaa975da893a45420698c209

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]