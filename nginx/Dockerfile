FROM nginx:1.25.4-alpine@sha256:02d8d94023878cedf3e3acc55372932a9ba1478b6e2f3357786d916c2af743ba

RUN apk upgrade --no-cache && apk add --no-cache shadow

COPY default.conf /etc/nginx/conf.d/default.conf
COPY errors/50x.html /usr/share/nginx/html/50x.html
