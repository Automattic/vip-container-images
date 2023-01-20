FROM ghcr.io/automattic/vip-container-images/alpine:3.17.1@sha256:fbd2cb3cd937080dd4a701d0433e7b0604260e3542a805cef815790e2f921ebf AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.17.1@sha256:fbd2cb3cd937080dd4a701d0433e7b0604260e3542a805cef815790e2f921ebf
RUN apk add --no-cache shadow
COPY --from=build /wordpress/wordpress/ /wp/
