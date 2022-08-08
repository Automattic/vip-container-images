FROM ghcr.io/automattic/vip-container-images/alpine:3.16.0@sha256:65a63720c74c978bcc1225803bb3c3e94922165c17814d599d8ac6dc11f32746

RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins /mu-plugins && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins-ext /mu-plugins-ext && \
    cd /mu-plugins && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init

COPY mu-plugins/run.sh mu-plugins/autoupdate.sh /

CMD ["sh", "/run.sh"]
