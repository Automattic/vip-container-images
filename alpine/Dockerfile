FROM alpine:3.18.5@sha256:34871e7290500828b39e22294660bee86d966bc0017544e848dd9a255cdf59e0

RUN apk upgrade --no-cache

# Common packages needed for most images
# - rsync: Needed to copy code to k8s/docker-compose volumes
# - shadow: Needed to setup Lando dev environments
RUN apk add --no-cache rsync shadow
