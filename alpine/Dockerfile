FROM alpine:3.22.2@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412

# Common packages needed for most images
# - rsync: Needed to copy code to k8s/docker-compose volumes
# - shadow: Needed to setup Lando dev environments
RUN apk upgrade --no-cache && apk add --no-cache rsync shadow
