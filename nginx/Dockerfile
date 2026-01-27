FROM nginx:1.29.4-alpine@sha256:b0f7830b6bfaa1258f45d94c240ab668ced1b3651c8a222aefe6683447c7bf55

RUN apk upgrade --no-cache && apk add --no-cache shadow openssl

COPY default.conf /etc/nginx/conf.d/default.conf
COPY errors/50x.html /usr/share/nginx/html/50x.html
