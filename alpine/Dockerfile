FROM alpine:3.17.1@sha256:f271e74b17ced29b915d351685fd4644785c6d1559dd1f2d4189a5e851ef753a

# Common packages needed for most images
# - rsync: Needed to copy code to k8s/docker-compose volumes
# - shadow: Needed to setup Lando dev environments
RUN apk add --no-cache rsync shadow
