FROM alpine:3.17.2@sha256:8a81a7c2af9caf25aa960c6ef70e198b2d7194841546d3b26c9a1eb308a360b3

# Common packages needed for most images
# - rsync: Needed to copy code to k8s/docker-compose volumes
# - shadow: Needed to setup Lando dev environments
RUN apk add --no-cache rsync shadow
