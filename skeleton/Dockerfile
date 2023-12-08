FROM ghcr.io/automattic/vip-container-images/alpine:3.19.0@sha256:43e68e32a67c813ffa4ee5a9355a353d42a24e307474978b765b91ab942b4758

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]