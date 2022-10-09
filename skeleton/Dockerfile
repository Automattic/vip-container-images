FROM ghcr.io/automattic/vip-container-images/alpine:3.16.2@sha256:b2ef666dad5ddb75226939e2cdd3a6dbc34fbdaed4b007606641ed74fe3fa42f

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]