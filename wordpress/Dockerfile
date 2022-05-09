FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:5e4f9539ec5e8a65182e25c0fb66c719323670b8fe84721ebe85ae5bd3ca9877 AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:5e4f9539ec5e8a65182e25c0fb66c719323670b8fe84721ebe85ae5bd3ca9877
COPY --from=build /wordpress/wordpress/ /wp/
