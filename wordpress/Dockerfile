FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:e3eae9b00692dc279d7efa683c44bd7ac4b0f5abcc9d96c4ba11f03851db9d95 AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:e3eae9b00692dc279d7efa683c44bd7ac4b0f5abcc9d96c4ba11f03851db9d95
COPY --from=build /wordpress/wordpress/ /wp/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
