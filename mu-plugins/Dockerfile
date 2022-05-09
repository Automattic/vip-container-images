FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:81651cfe524426b5066c9670d8b816a505a605df9e1d8c3d16097026388ee402

RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins /mu-plugins && \
    cd /mu-plugins && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init

COPY mu-plugins/run.sh mu-plugins/autoupdate.sh /

CMD ["sh", "/run.sh"]
