FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:9dc91d2344fb82783801aba97253aaef4eafae06dfd3117afe91be2a84463f00

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]