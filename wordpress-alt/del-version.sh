#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Usage: del-version.sh <gitref>"
    echo "  - <gitref>: changeset/tag from the WordPress git repository"
    exit 1
fi

exists=$(jq -r ".[] | select(.ref == \"${REF}\") | .ref" "${VERSIONS}")
if [ -n "${exists}" ]; then
    jq "del(.[] | select(.ref == \"${REF}\"))" "${VERSIONS}" | sponge "${VERSIONS}"
else
    echo "${REF} does not exist in versions.json"
fi
