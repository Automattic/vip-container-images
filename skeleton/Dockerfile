FROM ghcr.io/automattic/vip-container-images/alpine:3.16.3@sha256:1e915c312415f9347124214ba535752d83c9a3b81622c62defc02e8a1df8176a

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]