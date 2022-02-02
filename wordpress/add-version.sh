#!/bin/sh

if [ $# -lt 2 ]; then
    echo "Usage: add-version.sh <tag> <gitref> [cacheable] [locked] [prerelease]"
    echo "  - <tag>:        tag for the resulting Docker image"
    echo "  - <gitref>:     changeset/tag to import from the WordPress git repository"
    echo "  - [cacheable]:  optional parameter; if not empty, the ref will be marked as eligible for caching"
    echo "  - [locked]:     tag the image that it should be locked from automated curation"
    echo "  - [prerelease]: marks the image as using an unstable ref"
    exit 1
fi

TAG="$1"
REF="$2"

if [ -n "$3" ]; then
    CACHEABLE=true
else
    CACHEABLE=false
fi

if [ -n "$4" ]; then
    LOCKED=true
else
    LOCKED=false
fi

if [ -n "$5" ]; then
    PRERELEASE=true
else
    PRERELEASE=false
fi

VERSIONS="$(dirname "$0")/versions.json"

exists=$(jq -r ".[] | select(.tag == \"${TAG}\") | .ref" "${VERSIONS}")
if [ -z "${exists}" ]; then
    jq ". += [{ref: \"${REF}\", tag: \"${TAG}\", cacheable: ${CACHEABLE}, locked: ${LOCKED}, prerelease: ${PRERELEASE} }] | sort" "${VERSIONS}" | sponge "${VERSIONS}"
else
    echo "${TAG} already exists in versions.json"
fi
