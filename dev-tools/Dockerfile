FROM ghcr.io/automattic/vip-container-images/alpine:3.15.4@sha256:81651cfe524426b5066c9670d8b816a505a605df9e1d8c3d16097026388ee402

COPY dev-tools/setup.sh dev-tools/add-site.sh dev-tools/dev-env-plugin.php dev-tools/wp-config* /dev-tools/
COPY dev-tools/scripts /scripts

CMD ["sleep", "infinity"]