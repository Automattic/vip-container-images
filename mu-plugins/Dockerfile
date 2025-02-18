# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM ghcr.io/automattic/vip-container-images/alpine:3.21.2@sha256:210f0dbe29f1b100c10758521e61345bd60651b91e8f581d58be84bbdadd9e1d AS build

RUN apk add --no-cache git && mkdir -p /mu-plugins
RUN git clone --depth 1 --single-branch https://github.com/Automattic/vip-go-mu-plugins-ext /mu-plugins-ext
RUN git clone --depth 1 --no-remote-submodules --single-branch -b staging https://github.com/Automattic/vip-go-mu-plugins /mu-plugins-tmp
WORKDIR /mu-plugins-tmp
RUN sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && git submodule update --init --recursive --depth 1 --single-branch --jobs 8
RUN gitsha=$(git rev-parse --short HEAD) && gitdate=$(git show -s --format=%cs "$gitsha") && date=$(date -d "$gitdate" '+%Y%m%d') && echo "{ \"tag\": \"staging\", \"stack_version\": \"${date}-${gitsha}\" }" > "/mu-plugins/.version"
RUN rsync -a -r --delete --exclude-from="/mu-plugins-tmp/.dockerignore" /mu-plugins-tmp/* /mu-plugins
RUN rsync -a -r --delete --exclude-from="/mu-plugins-ext/.dockerignore" --exclude-from="/mu-plugins-ext/.devenvignore" /mu-plugins-ext/* /mu-plugins
RUN mkdir /shared

FROM ghcr.io/automattic/vip-container-images/helpers:v1@sha256:bc2beca042ce7c47e2b737920c77248f4a6c25cc7e137bf9de6944af8a68701c AS helpers
FROM busybox:stable-musl@sha256:7fe2d84eca21fa921a1006acaa68da15ed0acb7e1d21e5f3149bb6923af38498

COPY --from=build --link /shared /shared
COPY --from=helpers /rsync /usr/bin/rsync
COPY --from=build --link /mu-plugins /mu-plugins
COPY run.sh /run.sh

VOLUME ["/shared"]
