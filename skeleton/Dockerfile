FROM ghcr.io/automattic/vip-container-images/alpine:3.14.3@sha256:c77e81419a627dcd1ee94eca648150736f8bb632f95bbeffd630ae294253a68c

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]