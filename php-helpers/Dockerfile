FROM --platform=${BUILDPLATFORM} tonistiigi/xx:latest@sha256:010d4b66aed389848b0694f91c7aaee9df59a6f20be7f5d12e53663a37bd14e2 AS xx

FROM --platform=${BUILDPLATFORM} ubuntu:24.04@sha256:728785b59223d755e3e5c5af178fab1be7031f3522c5ccd7a0b32b80d8248123 AS common
ARG TARGETPLATFORM
COPY --from=xx / /
ENV DEBIAN_FRONTEND=noninteractive
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends clang cmake file lld make pkgconf && \
    xx-apt-get update && \
    xx-apt-get install -y binutils gcc g++ libc6-dev && \
    xx-clang --setup-target-triple && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

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
    apt-get install -y shtool php8.3-cli php8.3-xml php-pear && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* && \
    sed -i '/^Package: shtool$/a Multi-Arch: foreign' /var/lib/dpkg/status && \
    pecl bundle timezonedb



FROM --platform=${BUILDPLATFORM} common AS build-mydumper
ARG TARGETPLATFORM
RUN \
    echo 'DPkg::Pre-Invoke { "rm -f /var/lib/dpkg/info/*.postinst || true"; };' > /etc/apt/apt.conf.d/99local && \
    xx-apt-get update && \
    xx-apt-get install --no-install-recommends -y -oDPkg::ConfigurePending=0 libglib2.0-dev || true && \
    xx-apt-get install --no-install-recommends -y -oDPkg::ConfigurePending=0 libglib2.0-dev || true && \
    xx-apt-get install --no-install-recommends -y -oDPkg::ConfigurePending=0 libglib2.0-dev && \
    xx-apt-get install --no-install-recommends -y \
        zlib1g-dev libpcre3-dev libssl-dev libzstd-dev libmysqlclient-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /src/mydumper
ADD https://github.com/mydumper/mydumper/archive/refs/tags/v0.16.3-6.tar.gz mydumper.tar.gz
RUN \
    echo "6af51d6e18fdf318710ba0c3d87f6ac7 mydumper.tar.gz" | md5sum -c - && \
    tar -xzf mydumper.tar.gz --strip-components=1 && \
    sed -i 's/-Werror//g' CMakeLists.txt && \
    cmake -B build $(xx-clang --print-cmake-defines) && \
    cmake --build build -j$(nproc) && \
    cmake --install build && \
    rm -rf build



FROM --platform=${BUILDPLATFORM} php-common AS php81
WORKDIR /src/timezonedb
RUN \
    xx-apt-get update && \
    xx-apt-get install -y --no-install-recommends php8.1-dev && \
    phpize && ./configure --host=$(xx-clang --print-target-triple) && make -j$(nproc) && make install && \
    make distclean && \
    xx-apt-get remove --purge -y --auto-remove php8.1-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*



FROM --platform=${BUILDPLATFORM} php-common AS php82
WORKDIR /src/timezonedb
RUN \
    xx-apt-get update && \
    xx-apt-get install -y --no-install-recommends php8.2-dev && \
    phpize && ./configure --host=$(xx-clang --print-target-triple) && make -j$(nproc) && make install && \
    make distclean && \
    xx-apt-get remove --purge -y --auto-remove php8.2-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*



FROM --platform=${BUILDPLATFORM} php-common AS php83
WORKDIR /src/timezonedb
RUN \
    xx-apt-get update && \
    xx-apt-get install -y --no-install-recommends php8.3-dev && \
    phpize && ./configure --host=$(xx-clang --print-target-triple) && make -j$(nproc) && make install && \
    make distclean && \
    xx-apt-get remove --purge -y --auto-remove php8.3-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*



FROM --platform=${BUILDPLATFORM} php-common AS php84
WORKDIR /src/timezonedb
RUN \
    xx-apt-get update && \
    xx-apt-get install -y --no-install-recommends php8.4-dev && \
    phpize && ./configure --host=$(xx-clang --print-target-triple) && make -j$(nproc) && make install && \
    make distclean && \
    xx-apt-get remove --purge -y --auto-remove php8.4-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*



FROM scratch
COPY --from=build-mydumper /usr/local/bin/mydumper /usr/local/bin/myloader /etc/mydumper.cnf /
COPY --from=php81 /usr/lib/php/20210902/timezonedb.so /usr/lib/php/20210902/timezonedb.so
COPY --from=php82 /usr/lib/php/20220829/timezonedb.so /usr/lib/php/20220829/timezonedb.so
COPY --from=php83 /usr/lib/php/20230831/timezonedb.so /usr/lib/php/20230831/timezonedb.so
COPY --from=php84 /usr/lib/php/20240924/timezonedb.so /usr/lib/php/20240924/timezonedb.so
