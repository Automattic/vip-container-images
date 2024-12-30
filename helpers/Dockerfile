FROM --platform=${BUILDPLATFORM} tonistiigi/xx:latest@sha256:923441d7c25f1e2eb5789f82d987693c47b8ed987c4ab3b075d6ed2b5d6779a3 AS xx

FROM --platform=${BUILDPLATFORM} alpine:3.21.0@sha256:21dc6063fd678b478f57c0e13f47560d0ea4eeba26dfc947b2a4f81f686b9f45 AS common
COPY --from=xx / /

RUN apk add --no-cache clang file gawk lld make pkgconf

ENV SOURCE_DATE_EPOCH=0
ENV CC=xx-clang
ENV CXX=xx-clang++

ADD https://github.com/lz4/lz4/releases/download/v1.10.0/lz4-1.10.0.tar.gz /src/
ADD https://github.com/Cyan4973/xxHash/archive/v0.8.3.tar.gz /src/
ADD https://download.samba.org/pub/rsync/rsync-3.3.0.tar.gz /src/

WORKDIR /src
RUN \
    tar xzf lz4-1.10.0.tar.gz && \
    tar xzf v0.8.3.tar.gz && \
    tar xzf rsync-3.3.0.tar.gz

COPY . .

FROM --platform=${BUILDPLATFORM} common AS build
ARG TARGETPLATFORM

RUN xx-apk add --no-cache gcc musl-dev acl-dev acl-static attr-dev attr-static popt-dev popt-static zlib-dev zlib-static zstd-dev zstd-static
RUN xx-clang --setup-target-triple

WORKDIR /src/lz4-1.10.0
RUN \
    make BUILD_SHARED=no CFLAGS="-O3 -flto=auto" && \
    make -C lib install BUILD_SHARED=no PREFIX="$(xx-info sysroot)usr/local" 

WORKDIR /src/xxHash-0.8.3
RUN \
    make libxxhash.a CFLAGS="-DXXH_FORCE_MEMORY_ACCESS=1 -O3 -flto=auto" && \
    make install_libxxhash.a install_libxxhash.includes install_libxxhash.pc PREFIX="$(xx-info sysroot)usr/local"

WORKDIR /src/rsync-3.3.0
RUN \
    ./configure --host=$(xx-clang --print-target-triple) \
        --enable-acl-support --enable-xattr-support --disable-openssl --disable-debug --disable-md2man --disable-locale --without-included-popt --without-included-zlib \
        LDFLAGS="-L$(xx-info sysroot)usr/local/lib -s -static" CFLAGS="-O2 -flto=auto" && \
    make -j2 && \
    make install

WORKDIR /src
RUN xx-clang true.c -o /usr/local/bin/true -Os -s -static

FROM scratch
COPY --from=build /usr/local/bin /
