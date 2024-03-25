FROM nginx:1.25.4-alpine@sha256:31bad00311cb5eeb8a6648beadcf67277a175da89989f14727420a80e2e76742

RUN apk upgrade --no-cache && apk add --no-cache shadow

COPY default.conf /etc/nginx/conf.d/default.conf
COPY errors/50x.html /usr/share/nginx/html/50x.html
