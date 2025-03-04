FROM --platform=${BUILDPLATFORM} tonistiigi/xx:latest@sha256:923441d7c25f1e2eb5789f82d987693c47b8ed987c4ab3b075d6ed2b5d6779a3 AS xx

FROM --platform=${BUILDPLATFORM} ubuntu:24.04@sha256:2e863c44b718727c860746568e1d54afd13b2fa71b160f5cd9058fc436217b30 AS common
ARG TARGETPLATFORM
COPY --from=xx / /
ENV DEBIAN_FRONTEND=noninteractive
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends clang cmake file lld make pkgconf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN \
    xx-apt-get update && \
    xx-apt-get install -y binutils gcc g++ libc6-dev

ENV SOURCE_DATE_EPOCH=0

WORKDIR /src



FROM --platform=${BUILDPLATFORM} common AS php-common
ARG TARGETPLATFORM
RUN \
    apt-get update && \
    apt-get install -y curl lsb-release ca-certificates gnupg --no-install-recommends && \
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    curl -sSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x71DAEAAB4AD4CAB6" | gpg --dearmor > /etc/apt/trusted.gpg.d/ppa-ondrej-php.gpg && \
    xx-apt-get update && \
    apt-get install -y shtool php-pear && \
    sed -i '/^Package: shtool$/a Multi-Arch: foreign' /var/lib/dpkg/status && \
    pecl bundle timezonedb


FROM --platform=${BUILDPLATFORM} common AS build-mydumper
ARG TARGETPLATFORM

RUN \
    echo 'DPkg::Pre-Invoke { "rm -f /var/lib/dpkg/info/*.postinst || true"; };' > /etc/apt/apt.conf.d/99local && \
    xx-apt-get install --no-install-recommends -y -oDPkg::ConfigurePending=0 libglib2.0-dev || true && \
    xx-apt-get install --no-install-recommends -y -oDPkg::ConfigurePending=0 libglib2.0-dev || true && \
    xx-apt-get install --no-install-recommends -y -oDPkg::ConfigurePending=0 libglib2.0-dev && \
    xx-apt-get install --no-install-recommends -y -oDPkg::ConfigurePending=0 \
        zlib1g-dev libpcre3-dev libssl-dev libzstd-dev libmysqlclient-dev

RUN xx-clang --setup-target-triple

WORKDIR /src/mydumper
ADD https://github.com/mydumper/mydumper/archive/refs/tags/v0.18.1-1.tar.gz mydumper.tar.gz
RUN \
    echo "0cce6f1e15b474c35d57e9bcd87d8469 mydumper.tar.gz" | md5sum -c - && \
    tar -xzf mydumper.tar.gz --strip-components=1 && \
    sed -i 's/-Werror//g' CMakeLists.txt && \
    cmake -B build $(xx-clang --print-cmake-defines) && \
    cmake --build build -j$(nproc) && \
    cmake --install build



FROM --platform=${BUILDPLATFORM} php-common AS php81
RUN xx-apt-get install -y --no-install-recommends "php8.1-dev"
WORKDIR /src/timezonedb
RUN phpize && ./configure --host=$(xx-clang --print-target-triple) && make -j$(nproc) && make install



FROM --platform=${BUILDPLATFORM} php-common AS php82
RUN xx-apt-get install -y --no-install-recommends "php8.2-dev"
WORKDIR /src/timezonedb
RUN phpize && ./configure --host=$(xx-clang --print-target-triple) && make -j$(nproc) && make install



FROM --platform=${BUILDPLATFORM} php-common AS php83
RUN xx-apt-get install -y --no-install-recommends "php8.3-dev"
WORKDIR /src/timezonedb
RUN phpize && ./configure --host=$(xx-clang --print-target-triple) && make -j$(nproc) && make install



FROM --platform=${BUILDPLATFORM} php-common AS php84
RUN xx-apt-get install -y --no-install-recommends "php8.4-dev"
WORKDIR /src/timezonedb
RUN phpize && ./configure --host=$(xx-clang --print-target-triple) && make -j$(nproc) && make install



FROM scratch AS php
COPY --from=php81 /usr/lib/php/20210902/timezonedb.so /usr/lib/php/20210902/timezonedb.so
COPY --from=php82 /usr/lib/php/20220829/timezonedb.so /usr/lib/php/20220829/timezonedb.so
COPY --from=php83 /usr/lib/php/20230831/timezonedb.so /usr/lib/php/20230831/timezonedb.so
COPY --from=php84 /usr/lib/php/20240924/timezonedb.so /usr/lib/php/20240924/timezonedb.so



FROM scratch
COPY --from=build-mydumper /usr/local/bin/mydumper /usr/local/bin/myloader /etc/mydumper.cnf /
COPY --from=php /usr/lib/php /usr/lib/php
