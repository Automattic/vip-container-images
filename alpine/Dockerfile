FROM alpine:3.17.0@sha256:8914eb54f968791faf6a8638949e480fef81e697984fba772b3976835194c6d4

# Common packages needed for most images
# - rsync: Needed to copy code to k8s/docker-compose volumes
# - shadow: Needed to setup Lando dev environments
RUN apk add --no-cache rsync shadow