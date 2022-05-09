FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:5e4f9539ec5e8a65182e25c0fb66c719323670b8fe84721ebe85ae5bd3ca9877

RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins /mu-plugins && \
    cd /mu-plugins && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init

COPY mu-plugins/run.sh mu-plugins/autoupdate.sh /

CMD ["sh", "/run.sh"]
