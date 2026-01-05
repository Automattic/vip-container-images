FROM nginx:1.29.4-alpine@sha256:8491795299c8e739b7fcc6285d531d9812ce2666e07bd3dd8db00020ad132295

RUN apk upgrade --no-cache && apk add --no-cache shadow openssl

COPY default.conf /etc/nginx/conf.d/default.conf
COPY errors/50x.html /usr/share/nginx/html/50x.html
