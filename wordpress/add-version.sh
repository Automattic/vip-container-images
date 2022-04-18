#!/bin/sh

if [ $# -lt 2 ]; then
    echo "Usage: add-version.sh <tag> <gitref> [cacheable] [locked] [prerelease]"
    echo "  - <tag>:        tag for the resulting Docker image"
    echo "  - <gitref>:     changeset/tag to import from the WordPress git repository"
    echo "  - [cacheable]:  optional parameter; if not false, the ref will be marked as eligible for caching"
    echo "  - [locked]:     optional parameter; if true mark the image that it should be locked"
    echo "  - [prerelease]: optional parameter; if true marks the image as using an unstable ref"
    exit 1
fi

TAG="$1"
REF="$2"

CACHEABLE=true
if [ -n "$3" ]; then
    if [ "$3" == "false" ]; then
        CACHEABLE=false
    fi
fi

LOCKED=false
if [ -n "$4" ]; then
    if [ "$4" == "true" ]; then
        LOCKED=true
    fi
fi

PRERELEASE=false
if [ -n "$5" ]; then
    if [ "$5" == "true" ]; then
        PRERELEASE=true
    fi
fi
echo ""
echo "Adding version: $TAG at ref: $REF"
echo "Cacheable: $CACHEABLE"
echo "Locked: $LOCKED"
echo "Prerelease: $PRERELEASE"

VERSIONS="$(dirname "$0")/versions.json"

exists=$(jq -r ".[] | select(.tag == \"${TAG}\") | .ref" "${VERSIONS}")
if [ -z "${exists}" ]; then
    jq ". += [{ref: \"${REF}\", tag: \"${TAG}\", cacheable: ${CACHEABLE}, locked: ${LOCKED}, prerelease: ${PRERELEASE} }] | sort_by(.tag) | reverse" "${VERSIONS}" | sponge "${VERSIONS}"
else
    echo "${TAG} already exists in versions.json"
fi
