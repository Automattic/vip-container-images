FROM statsd/statsd:v0.9.0@sha256:d7e6f2261ffeb96eff30f04c77e46959a6ddb23c492675196ceaeac5947e898c

COPY statsd/statsd-config.js /config/statsd-config.js

CMD ["node", "/usr/src/app/stats.js", "/config/statsd-config.js"]