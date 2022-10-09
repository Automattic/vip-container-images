FROM ghcr.io/automattic/vip-container-images/alpine:3.16.2@sha256:007a0e43847590036e3c46fdf91f5af8b2b1e735fc271709a45af511b41c0667

COPY dev-tools/setup.sh dev-tools/add-site.sh dev-tools/dev-env-plugin.php dev-tools/wp-config* /dev-tools/
COPY dev-tools/scripts /scripts

CMD ["sleep", "infinity"]