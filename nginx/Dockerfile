FROM nginx:1.25.3-alpine@sha256:db353d0f0c479c91bd15e01fc68ed0f33d9c4c52f3415e63332c3d0bf7a4bb77

RUN apk add --no-cache shadow

COPY default.conf /etc/nginx/conf.d/default.conf
