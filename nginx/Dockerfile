FROM nginx:1.25.5-alpine@sha256:7bd88800d8c18d4f73feeee25e04fcdbeecfc5e0a2b7254a90f4816bb67beadd

RUN apk upgrade --no-cache && apk add --no-cache shadow

COPY default.conf /etc/nginx/conf.d/default.conf
COPY errors/50x.html /usr/share/nginx/html/50x.html
