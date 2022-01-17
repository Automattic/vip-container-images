#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Syntax: add-version.sh <version> <gitref>"
  echo "  <version>  Name of the version as we are going to reference it in VIP"
  echo "  <gitref>   Changeset/tag to import from the WordPress git repository"
  echo
  echo "Examples:"
  echo "$ add-version.sh 5.5.1     5.5.1"
  echo "$ add-version.sh 5.6-beta1 7e29e531bd"
  exit 1
fi

version=$1
ref=$2

tree_dir="wordpress/public/${version}"

echo
echo "====================================="
echo "Creating subtree public/$version"
echo "====================================="
echo
git subtree add -P "$tree_dir" https://github.com/WordPress/WordPress "$ref" --squash -m "Add public WordPress $version"

wordpress/patch-version.sh ${version}
