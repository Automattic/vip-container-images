FROM nginx:1.23.1-alpine@sha256:b87c350e6c69e0dc7069093dcda226c4430f3836682af4f649f2af9e9b5f1c74

RUN apk add --no-cache openssl

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]