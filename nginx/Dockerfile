FROM nginx:1.25.1-alpine@sha256:647c5c83418c19eef0cddc647b9899326e3081576390c4c7baa4fce545123b6c

RUN apk add --no-cache shadow

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
