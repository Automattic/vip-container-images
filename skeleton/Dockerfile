FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:554a468a641614c648f1fffdc21d2b76dfa598f28fd2a3bf71435532897312e6

RUN apk add --no-cache --virtual build-deps git && \
    git clone --depth=1 https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    rm -rf /clientcode/.git && \
    apk del --no-cache build-deps

CMD ["sleep", "infinity"]