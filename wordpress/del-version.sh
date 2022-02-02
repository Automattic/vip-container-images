#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Usage: del-version.sh <tag>"
    echo "  - <tag>: changeset/tag from the WordPress git repository"
    exit 1
fi

TAG="$1"

VERSIONS="$(dirname "$0")/versions.json"

exists=$(jq -r ".[] | select(.tag == \"${TAG}\") | .ref" "${VERSIONS}")
if [ -n "${exists}" ]; then
    jq "del(.[] | select(.tag == \"${TAG}\"))" "${VERSIONS}" | sponge "${VERSIONS}"
else
    echo "${REF} does not exist in versions.json"
fi
