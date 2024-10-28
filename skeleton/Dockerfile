FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:c67d7460ba70b45bb0d887a5fa6b5449a1c1c453b792bfcf67e643a341c1ca64

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]