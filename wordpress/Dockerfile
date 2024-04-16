FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:2532a75a8ce1691b51ff84fcfd840bbe98bd09dbf7a0b58cad77f16294ffe202 AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.19.1@sha256:2532a75a8ce1691b51ff84fcfd840bbe98bd09dbf7a0b58cad77f16294ffe202
COPY --from=build /wordpress/wordpress/ /wp/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
