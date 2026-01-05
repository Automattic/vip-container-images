# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM ghcr.io/automattic/vip-container-images/alpine:3.23.2@sha256:5ad8cc0d641da46392429643e880c54b31ba27188091be2235b17f360f3740fc AS build

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
FROM busybox:stable-musl@sha256:a56f14592e5a275b6f2d22197ba51ba9aaa24b75d8d4bb4579418e61fdcaae83

COPY --from=build --link /shared /shared
COPY --from=helpers /rsync /usr/bin/rsync
COPY --from=build --link /mu-plugins /mu-plugins
COPY run.sh /run.sh

VOLUME ["/shared"]
