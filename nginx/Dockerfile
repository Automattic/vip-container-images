FROM nginx:1.23.3-alpine@sha256:8ca95a5304466bf143cb35d2eae8825ac3cb061f5d1df34b3d9db5c925687560

RUN apk add --no-cache shadow

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
