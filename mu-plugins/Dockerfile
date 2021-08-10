FROM ghcr.io/automattic/vip-container-images/alpine:3.12.7

RUN apk add --no-cache git rsync && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins /mu-plugins && \
    cd /mu-plugins && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init

COPY mu-plugins/run.sh /run.sh
COPY mu-plugins/autoupdate.sh /autoupdate.sh

CMD ["sh", "/run.sh"]