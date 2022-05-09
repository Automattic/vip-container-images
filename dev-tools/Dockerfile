FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:65b761bde98b9d3e4b10d642b924359a58cafbd2d510a00091be0eb623143d8f

COPY dev-tools/setup.sh dev-tools/add-site.sh dev-tools/dev-env-plugin.php dev-tools/wp-config* /dev-tools/
COPY dev-tools/scripts /scripts

CMD ["sleep", "infinity"]