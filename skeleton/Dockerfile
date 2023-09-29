FROM ghcr.io/automattic/vip-container-images/alpine:3.18.4@sha256:5dff371776f49fdb822934ac54b1073e9505e824734b3ab589688071bf97e753

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]