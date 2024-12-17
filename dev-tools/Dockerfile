FROM ghcr.io/automattic/vip-container-images/helpers:v1@sha256:bc2beca042ce7c47e2b737920c77248f4a6c25cc7e137bf9de6944af8a68701c AS helpers
FROM busybox:stable-musl@sha256:b4771ab006a5344931341972e1e4b1ff14db2c327eeab0053416aa2277213b1d

COPY --from=helpers /rsync /usr/bin/rsync
COPY --link setup.sh add-site.sh dev-env-plugin.php wp-config* /dev-tools-orig/
COPY --link setup.sh add-site.sh dev-env-plugin.php wp-config* /dev-tools/
COPY --link scripts /scripts

ENTRYPOINT ["/usr/bin/rsync", "-a", "--delete", "/dev-tools-orig/", "/dev-tools/"]
