# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM scratch AS build
ARG WP_GIT_REF
ADD https://github.com/WordPress/WordPress/archive/refs/tags/${WP_GIT_REF}.tar.gz /wp/
COPY extra/ /wp/

FROM ghcr.io/automattic/vip-container-images/helpers:v1@sha256:bc2beca042ce7c47e2b737920c77248f4a6c25cc7e137bf9de6944af8a68701c AS helpers
FROM busybox:stable-musl@sha256:b4771ab006a5344931341972e1e4b1ff14db2c327eeab0053416aa2277213b1d
COPY --from=build --link --chown=1000:1000 /wp /wp
COPY --from=helpers /rsync /usr/bin/rsync
