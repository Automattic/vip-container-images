FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:81651cfe524426b5066c9670d8b816a505a605df9e1d8c3d16097026388ee402 AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:81651cfe524426b5066c9670d8b816a505a605df9e1d8c3d16097026388ee402
COPY --from=build /wordpress/wordpress/ /wp/
