FROM ghcr.io/automattic/vip-container-images/alpine:3.17.3@sha256:062a1ec3e5d1d7c471add8bb689ccd26a3d6a734c802bbbc37d8f456ddb27b40 AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.17.3@sha256:062a1ec3e5d1d7c471add8bb689ccd26a3d6a734c802bbbc37d8f456ddb27b40
COPY --from=build /wordpress/wordpress/ /wp/
