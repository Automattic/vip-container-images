# syntax=docker/dockerfile:1.7
FROM --platform=$BUILDPLATFORM ghcr.io/automattic/vip-container-images/alpine:3.21.0@sha256:32cff7c1b6fe35a9f3d0c829a5a29ca80761a19ae63c15c914bf4c03fbf7df66 AS build

RUN apk add --no-cache git && mkdir -p /mu-plugins
RUN git clone --depth 1 --single-branch https://github.com/Automattic/vip-go-mu-plugins-ext /mu-plugins-ext
RUN git clone --depth 1 --no-remote-submodules --single-branch -b staging https://github.com/Automattic/vip-go-mu-plugins /mu-plugins-tmp
WORKDIR /mu-plugins-tmp
RUN sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && git submodule update --init --recursive --depth 1 --single-branch --jobs 8
RUN gitsha=$(git rev-parse --short HEAD) && gitdate=$(git show -s --format=%cs "$gitsha") && date=$(date -d "$gitdate" '+%Y%m%d') && echo "{ \"tag\": \"staging\", \"stack_version\": \"${date}-${gitsha}\" }" > "/mu-plugins/.version"
RUN rsync -a -r --delete --exclude-from="/mu-plugins-tmp/.dockerignore" /mu-plugins-tmp/* /mu-plugins
RUN rsync -a -r --delete --exclude-from="/mu-plugins-ext/.dockerignore" --exclude-from="/mu-plugins-ext/.devenvignore" /mu-plugins-ext/* /mu-plugins


FROM ghcr.io/automattic/vip-container-images/alpine:3.21.0@sha256:32cff7c1b6fe35a9f3d0c829a5a29ca80761a19ae63c15c914bf4c03fbf7df66

RUN install -d -m 0755 /shared
COPY --from=build /mu-plugins /mu-plugins
COPY run.sh /run.sh

VOLUME ["/shared"]
CMD ["/bin/sh", "/run.sh"]
