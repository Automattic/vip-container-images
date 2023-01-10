FROM ghcr.io/automattic/vip-container-images/alpine:3.17.1@sha256:fbd2cb3cd937080dd4a701d0433e7b0604260e3542a805cef815790e2f921ebf

COPY dev-tools/setup.sh dev-tools/add-site.sh dev-tools/dev-env-plugin.php dev-tools/wp-config* /dev-tools/
COPY dev-tools/scripts /scripts

CMD ["sleep", "infinity"]