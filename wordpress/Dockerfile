FROM ghcr.io/automattic/vip-container-images/alpine:3.16.2@sha256:ed50c1b92ec84e58d7d67ec993d535591b6654e0ff8bced1e441b89503a31ae6 AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.16.2@sha256:ed50c1b92ec84e58d7d67ec993d535591b6654e0ff8bced1e441b89503a31ae6
COPY --from=build /wordpress/wordpress/ /wp/
