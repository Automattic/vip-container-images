FROM nginx:1.27.0-alpine@sha256:1e67a3c8607fe555f47dc8a72f25424b10273639136c061c508628da3112f90e

RUN apk upgrade --no-cache && apk add --no-cache shadow openssl

COPY default.conf /etc/nginx/conf.d/default.conf
COPY errors/50x.html /usr/share/nginx/html/50x.html
