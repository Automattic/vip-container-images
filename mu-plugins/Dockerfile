FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:65b761bde98b9d3e4b10d642b924359a58cafbd2d510a00091be0eb623143d8f

RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins /mu-plugins && \
    cd /mu-plugins && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init

COPY mu-plugins/run.sh mu-plugins/autoupdate.sh /

CMD ["sh", "/run.sh"]
