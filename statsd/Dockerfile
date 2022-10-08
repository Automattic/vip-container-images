FROM statsd/statsd:v0.9.0@sha256:d7e6f2261ffeb96eff30f04c77e46959a6ddb23c492675196ceaeac5947e898c AS build

FROM node:gallium-bullseye-slim@sha256:4fc367c89d498b455c6497cdd6211cc6a180bede77d8df80dea9acbcd5ffa19c

WORKDIR /usr/src/app
COPY --from=build /usr/src/app/ /usr/src/app/

EXPOSE 8126 8125/udp

COPY statsd-config.js /config/statsd-config.js

CMD ["/usr/local/bin/node", "/usr/src/app/stats.js", "/config/statsd-config.js"]
