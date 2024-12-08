# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM scratch AS build
ARG WP_GIT_REF
ADD https://github.com/WordPress/WordPress.git#${WP_GIT_REF} /wp
COPY extra/ /wp/

FROM ghcr.io/automattic/vip-container-images/alpine:3.21.0@sha256:32cff7c1b6fe35a9f3d0c829a5a29ca80761a19ae63c15c914bf4c03fbf7df66
COPY --from=build /wp /wp
