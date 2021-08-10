FROM statsd/statsd:v0.9.0

COPY statsd/statsd-config.js /config/statsd-config.js

CMD ["node", "/usr/src/app/stats.js", "/config/statsd-config.js"]