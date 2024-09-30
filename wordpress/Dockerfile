# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:90c4596fadb8a2f99c0aeb10aac6833126ae2cc18e8d2336d9067eb68595f61a AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.20.3@sha256:90c4596fadb8a2f99c0aeb10aac6833126ae2cc18e8d2336d9067eb68595f61a
COPY --from=build /wordpress/wordpress/ /wp/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
