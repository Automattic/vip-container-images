# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM scratch AS build
ARG WP_GIT_REF
ADD https://github.com/WordPress/WordPress.git#${WP_GIT_REF} /wp
COPY extra/ /wp/

FROM ghcr.io/automattic/vip-container-images/alpine:3.21.0@sha256:f03b90e4fdc9f54dc8cde68e4f8b2c97c7ee490d14bd18769d596b3269dda496
COPY --from=build /wp /wp
