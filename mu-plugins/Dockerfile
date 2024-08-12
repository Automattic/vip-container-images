FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:9c3f9e1e1b84ca2acd715a2c9965bea0b8459f0e3267d7612d9c1da5ed7e9e20 AS build

RUN apk add --no-cache git && mkdir -p /mu-plugins
RUN git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins-ext /mu-plugins-ext
RUN git clone --depth 1 --no-remote-submodules -b staging https://github.com/Automattic/vip-go-mu-plugins /mu-plugins-tmp
WORKDIR /mu-plugins-tmp
RUN sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && git submodule update --init --recursive --depth 1 --single-branch --jobs 8
RUN gitsha=$(git rev-parse --short HEAD) && gitdate=$(git show -s --format=%cs "$gitsha") && date=$(date -d "$gitdate" '+%Y%m%d') && echo "{ \"tag\": \"staging\", \"stack_version\": \"${date}-${gitsha}\" }" > "/mu-plugins/.version"
RUN rsync -a -r --delete --exclude-from="/mu-plugins-tmp/.dockerignore" /mu-plugins-tmp/* /mu-plugins
RUN rsync -a -r --delete --exclude-from="/mu-plugins-ext/.dockerignore" --exclude-from="/mu-plugins-ext/.devenvignore" /mu-plugins-ext/* /mu-plugins


FROM ghcr.io/automattic/vip-container-images/alpine:3.20.2@sha256:9c3f9e1e1b84ca2acd715a2c9965bea0b8459f0e3267d7612d9c1da5ed7e9e20

RUN install -d -m 0755 /shared
COPY --from=build /mu-plugins /mu-plugins
COPY run.sh /run.sh

VOLUME ["/shared"]
CMD ["/bin/sh", "/run.sh"]
