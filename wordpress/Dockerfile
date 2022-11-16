FROM ghcr.io/automattic/vip-container-images/alpine:3.16.3@sha256:1e915c312415f9347124214ba535752d83c9a3b81622c62defc02e8a1df8176a AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.16.3@sha256:1e915c312415f9347124214ba535752d83c9a3b81622c62defc02e8a1df8176a
COPY --from=build /wordpress/wordpress/ /wp/
