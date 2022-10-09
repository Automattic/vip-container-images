FROM ghcr.io/automattic/vip-container-images/alpine:3.16.2@sha256:ed50c1b92ec84e58d7d67ec993d535591b6654e0ff8bced1e441b89503a31ae6

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]