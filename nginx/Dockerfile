FROM nginx:1.23.3-alpine@sha256:bd4a0d3fcf54b86401bdc0035772467453a04715343e64af763112a87e4b3f2f

RUN apk add --no-cache shadow

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
