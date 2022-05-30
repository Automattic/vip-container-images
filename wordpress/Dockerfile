FROM ghcr.io/automattic/vip-container-images/alpine:3.16.0@sha256:65a63720c74c978bcc1225803bb3c3e94922165c17814d599d8ac6dc11f32746 AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.16.0@sha256:65a63720c74c978bcc1225803bb3c3e94922165c17814d599d8ac6dc11f32746
COPY --from=build /wordpress/wordpress/ /wp/
