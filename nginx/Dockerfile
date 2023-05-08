FROM nginx:1.23.4-alpine@sha256:02ffd439b71d9ea9408e449b568f65c0bbbb94bebd8750f1d80231ab6496008e

RUN apk add --no-cache shadow

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
