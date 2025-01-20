# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM scratch AS build
ARG WP_GIT_REF
ADD https://github.com/WordPress/WordPress.git#${WP_GIT_REF} /wp
COPY extra/ /wp/

FROM ghcr.io/automattic/vip-container-images/helpers:v1@sha256:bc2beca042ce7c47e2b737920c77248f4a6c25cc7e137bf9de6944af8a68701c AS helpers
FROM busybox:stable-musl@sha256:7fe2d84eca21fa921a1006acaa68da15ed0acb7e1d21e5f3149bb6923af38498
COPY --from=build --link /wp /wp
COPY --link dev-tools /dev-tools
COPY --link dev-tools /dev-tools-orig
COPY --link scripts /scripts
COPY --from=helpers /rsync /usr/bin/rsync
