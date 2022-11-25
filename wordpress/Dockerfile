FROM ghcr.io/automattic/vip-container-images/alpine:3.17.0@sha256:755d1f3dc85bfa36a20290c6b76644c3bfee6fa8aaa975da893a45420698c209 AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.17.0@sha256:755d1f3dc85bfa36a20290c6b76644c3bfee6fa8aaa975da893a45420698c209
COPY --from=build /wordpress/wordpress/ /wp/
