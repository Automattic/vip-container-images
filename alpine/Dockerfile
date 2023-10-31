FROM alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

RUN apk upgrade --no-cache

# Common packages needed for most images
# - rsync: Needed to copy code to k8s/docker-compose volumes
# - shadow: Needed to setup Lando dev environments
RUN apk add --no-cache rsync shadow
