# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:a41a67d60109e556da61a85aa261313cd91d6676b139750496b9eb5d4fb87db8 AS build
ARG WP_GIT_REF
RUN apk add --no-cache git git-subtree patch
RUN mkdir /wordpress
WORKDIR /wordpress

RUN \
    git config --global init.defaultBranch master && \
    git config --global user.email "no-reply@automattic.com" && \
    git config --global user.name "Build Bot"

RUN \
    git init . && \
    git commit --allow-empty -n -m "Initial commit." && \
    git subtree add -P wordpress https://github.com/WordPress/WordPress "$WP_GIT_REF" --squash && \
    rm -rf .git

COPY extra/ /wordpress/wordpress/

FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:a41a67d60109e556da61a85aa261313cd91d6676b139750496b9eb5d4fb87db8
COPY --from=build /wordpress/wordpress/ /wp/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
