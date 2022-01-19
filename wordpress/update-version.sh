#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Syntax: update-version.sh <version> <gitref>"
  echo "  <version>  Name of the version as we are going to reference it in VIP"
  echo "  <gitref>   Changeset/tag to import from the WordPress git repository"
  echo
  echo "Examples:"
  echo "$ update-version.sh 5.9.1"
  exit 1
fi

version=$1
ref=$([ "$2" == "" ] && echo "$1" || echo "$2")
ev="${version/\./\.}"
pattern=$(printf '      - name: Build %s container image((.|\\n)*):%s' "$ev" "$ev")

tree_dir="wordpress/public/${version}"
if [ ! -d "$tree_dir" ]; then
  echo "Subtree directory $tree_dir doesn't exist, cannot update it"
  exit 1
fi

# clean subtree branch
git stash

echo "Updating WordPress subtree $tree_dir to the tag/ref $ref"

git subtree pull --squash -P $tree_dir https://github.com/WordPress/WordPress $ref -m "Update WordPress subtree $tree_dir to the tag/ref $ref"

# detect if subtree pull created any changes
working_dir=$(git diff --quiet || echo changed)

if [ $working_dir == "changed" ]; then
  # remove build from .github/workflows/wordpress.yml
    perl -i -pe "BEGIN{undef $/;} s/$pattern//smg" .github/workflows/wordpress.yml

    wordpress/patch-version.sh ${version}
else
    echo
    echo "====================================="
    echo "No changes were staged for update"
    echo "====================================="
    echo
fi


