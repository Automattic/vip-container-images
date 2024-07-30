FROM nginx:1.27.0-alpine@sha256:208b70eefac13ee9be00e486f79c695b15cef861c680527171a27d253d834be9

RUN apk upgrade --no-cache && apk add --no-cache shadow openssl

COPY default.conf /etc/nginx/conf.d/default.conf
COPY errors/50x.html /usr/share/nginx/html/50x.html
