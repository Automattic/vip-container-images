# syntax=docker/dockerfile:1.7
FROM scratch AS build
ARG BRANCH
ADD https://github.com/Automattic/vip-go-mu-plugins-wpcloud.git#${BRANCH} .

FROM ghcr.io/automattic/vip-container-images/helpers:v1@sha256:6e27a9d364109f195cc518a3f58add74ffd51c574d5b1fa7acbbb19410e08e43 AS helpers
FROM busybox:stable-musl@sha256:74322b4716a11835c6f413fe9ffc2608ffdb8452f51cad9514a2b804908dc16e AS busybox
RUN mkdir /shared

FROM scratch
COPY --from=helpers /rsync /usr/bin/rsync
COPY --from=busybox /bin/busybox /bin/
COPY --from=build --link /wordpress/mu-plugins /mu-plugins
COPY run.sh /run.sh
RUN ["/bin/busybox", "--install", "-s"]

VOLUME ["/shared"]
