FROM ghcr.io/automattic/vip-container-images/alpine:3.17.0@sha256:755d1f3dc85bfa36a20290c6b76644c3bfee6fa8aaa975da893a45420698c209

COPY dev-tools/setup.sh dev-tools/add-site.sh dev-tools/dev-env-plugin.php dev-tools/wp-config* /dev-tools/
COPY dev-tools/scripts /scripts

CMD ["sleep", "infinity"]