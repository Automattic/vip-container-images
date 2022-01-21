#!/bin/sh

if [ $# -lt 2 ]; then
    echo "Usage: add-version.sh <gitref> <tag>"
    echo "  - <gitref>: changeset/tag to import from the WordPress git repository"
    echo "  - <tag>:    tag for the resulting Docker image"
    exit 1
fi

REF="$1"
TAG="$2"
VERSIONS="$(dirname "$0")/versions.json"

exists=$(jq -r ".[] | select(.ref == \"${REF}\") | .ref" "${VERSIONS}")
if [ -z "${exists}" ]; then
    jq ". += [{ref: \"${REF}\", tag: \"${TAG}\"}] | sort" "${VERSIONS}" | sponge "${VERSIONS}"
else
    echo "${REF} already exists in versions.json"
fi
