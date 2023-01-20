FROM nginx:1.23.3-alpine@sha256:659610aadb34b7967dea7686926fdcf08d588a71c5121edb094ce0e4cdbc45e6

RUN apk add --no-cache openssl shadow

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
