#!/bin/sh

jq '{ WORDPRESS_VERSIONS: . }' ../wordpress/versions.json > wordpress.json
docker buildx bake -f variables.hcl -f wordpress.json -f docker-bake.hcl --load
