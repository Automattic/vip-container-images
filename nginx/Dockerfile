FROM nginx:1.27.0-alpine@sha256:69f8c2c72671490607f52122be2af27d4fc09657ff57e42045801aa93d2090f7

RUN apk upgrade --no-cache && apk add --no-cache shadow openssl

COPY default.conf /etc/nginx/conf.d/default.conf
COPY errors/50x.html /usr/share/nginx/html/50x.html
