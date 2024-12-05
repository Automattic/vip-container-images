FROM ghcr.io/automattic/vip-container-images/alpine:3.21.0@sha256:32cff7c1b6fe35a9f3d0c829a5a29ca80761a19ae63c15c914bf4c03fbf7df66

COPY setup.sh add-site.sh dev-env-plugin.php wp-config* /dev-tools-orig/
COPY setup.sh add-site.sh dev-env-plugin.php wp-config* /dev-tools/
COPY scripts /scripts

ENTRYPOINT ["/usr/bin/rsync", "-a", "--delete", "/dev-tools-orig/", "/dev-tools/"]
