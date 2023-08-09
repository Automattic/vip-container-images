FROM ghcr.io/automattic/vip-container-images/alpine:3.18.3@sha256:3ce417e785786119ded6f22268ce321153a22a9aef2ec6f0ac44773a08bfc3d4 AS build
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

FROM ghcr.io/automattic/vip-container-images/alpine:3.18.3@sha256:3ce417e785786119ded6f22268ce321153a22a9aef2ec6f0ac44773a08bfc3d4
COPY --from=build /wordpress/wordpress/ /wp/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
