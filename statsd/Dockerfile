FROM statsd/statsd:v0.9.0@sha256:d7e6f2261ffeb96eff30f04c77e46959a6ddb23c492675196ceaeac5947e898c AS build

FROM node:gallium-bullseye-slim@sha256:5c9f79e11b4f867582241b5e7db96bbe1893fad8c1f523261690c743d0950667

WORKDIR /usr/src/app
COPY --from=build /usr/src/app/ /usr/src/app/

EXPOSE 8126 8125/udp

COPY statsd-config.js /config/statsd-config.js

CMD ["/usr/local/bin/node", "/usr/src/app/stats.js", "/config/statsd-config.js"]
