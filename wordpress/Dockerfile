# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM ghcr.io/automattic/vip-container-images/alpine:3.21.0@sha256:32cff7c1b6fe35a9f3d0c829a5a29ca80761a19ae63c15c914bf4c03fbf7df66 AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.21.0@sha256:32cff7c1b6fe35a9f3d0c829a5a29ca80761a19ae63c15c914bf4c03fbf7df66
COPY --from=build /wordpress/wordpress/ /wp/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
