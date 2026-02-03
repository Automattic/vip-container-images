# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM alpine:3.23.2@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62 AS build

RUN apk add --no-cache git rsync && mkdir -p /mu-plugins
RUN git clone --depth 1 --single-branch https://github.com/Automattic/vip-go-mu-plugins-ext /mu-plugins-ext
RUN git clone --depth 1 --no-remote-submodules --single-branch -b staging https://github.com/Automattic/vip-go-mu-plugins /mu-plugins-tmp
WORKDIR /mu-plugins-tmp
RUN sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && git submodule update --init --recursive --depth 1 --single-branch --jobs 8
RUN gitsha=$(git rev-parse --short HEAD) && gitdate=$(git show -s --format=%cs "$gitsha") && date=$(date -d "$gitdate" '+%Y%m%d') && echo "{ \"tag\": \"staging\", \"stack_version\": \"${date}-${gitsha}\" }" > "/mu-plugins/.version"
RUN rsync -a -r --delete --exclude-from="/mu-plugins-tmp/.dockerignore" /mu-plugins-tmp/* /mu-plugins
RUN rsync -a -r --delete --exclude-from="/mu-plugins-ext/.dockerignore" --exclude-from="/mu-plugins-ext/.devenvignore" /mu-plugins-ext/* /mu-plugins
RUN mkdir /shared

FROM ghcr.io/automattic/vip-container-images/helpers:v1@sha256:35163555a35cf836a1ec71c525cebd98c4abefa319b73e0328f9d7e6007dd420 AS helpers
FROM busybox:stable-musl@sha256:a81cb4eb87319424f704f7ab455a164c92ce032b82ff4832ee402820ae5d3c76

COPY --from=build --link /shared /shared
COPY --from=helpers /rsync /usr/bin/rsync
COPY --from=build --link /mu-plugins /mu-plugins
COPY run.sh /run.sh

VOLUME ["/shared"]
