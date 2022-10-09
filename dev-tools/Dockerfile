FROM ghcr.io/automattic/vip-container-images/alpine:3.16.2@sha256:ed50c1b92ec84e58d7d67ec993d535591b6654e0ff8bced1e441b89503a31ae6

COPY dev-tools/setup.sh dev-tools/add-site.sh dev-tools/dev-env-plugin.php dev-tools/wp-config* /dev-tools/
COPY dev-tools/scripts /scripts

CMD ["sleep", "infinity"]