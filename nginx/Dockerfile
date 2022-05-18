FROM nginx:1.21.6-alpine@sha256:a74534e76ee1121d418fa7394ca930eb67440deda413848bc67c68138535b989

RUN apk add --no-cache openssl

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]