FROM ghcr.io/automattic/vip-container-images/alpine:3.16.2@sha256:ef724194a4da6ffd3bc50e182cbaa88c599547bf9fabf9e4a6f6d58482688e6d AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.16.2@sha256:ef724194a4da6ffd3bc50e182cbaa88c599547bf9fabf9e4a6f6d58482688e6d
COPY --from=build /wordpress/wordpress/ /wp/
