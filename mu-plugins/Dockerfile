FROM ghcr.io/automattic/vip-container-images/alpine:3.14.3@sha256:c77e81419a627dcd1ee94eca648150736f8bb632f95bbeffd630ae294253a68c

RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins /mu-plugins && \
    cd /mu-plugins && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init

COPY mu-plugins/run.sh mu-plugins/autoupdate.sh /

CMD ["sh", "/run.sh"]
