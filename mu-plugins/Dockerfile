FROM ghcr.io/automattic/vip-container-images/alpine:3.16.3@sha256:1e915c312415f9347124214ba535752d83c9a3b81622c62defc02e8a1df8176a

RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins /mu-plugins && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins-ext /mu-plugins-ext && \
    cd /mu-plugins && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init

COPY mu-plugins/run.sh mu-plugins/autoupdate.sh /

CMD ["sh", "/run.sh"]
