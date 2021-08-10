FROM statsd/statsd:v0.8.6

COPY statsd-config.js /config/statsd-config.js

CMD ["node", "/usr/src/app/stats.js", "/config/statsd-config.js"]