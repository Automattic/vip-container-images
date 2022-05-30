FROM ghcr.io/automattic/vip-container-images/alpine:3.16.0@sha256:65a63720c74c978bcc1225803bb3c3e94922165c17814d599d8ac6dc11f32746

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]