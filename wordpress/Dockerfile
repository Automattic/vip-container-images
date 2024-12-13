# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM scratch AS build
ARG WP_GIT_REF
ADD https://github.com/WordPress/WordPress.git#${WP_GIT_REF} /wp
COPY extra/ /wp/

FROM ghcr.io/automattic/vip-container-images/helpers:v1@sha256:9f77c3da2ca0394d5846a9fc4195041f59ff5821ea6a7aaa43a08f15d28bf1eb AS helpers
FROM busybox:stable-musl@sha256:0fc05e424940109068f4d6562b699da2563cd8521a35d7b216a5b0c51fb29281
COPY --from=build --link /wp /wp
COPY --from=helpers /rsync /usr/bin/rsync
