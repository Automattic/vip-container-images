#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Syntax: delete-version.sh <version> <gitref>"
  echo "  <version>  Name of the version as we are going to reference it in VIP"
  echo
  echo "Examples:"
  echo "$ delete-version.sh 5.9.1"
  exit 1
fi

version=$1

tree_dir="wordpress/public/${version}"
if [ ! -d "$tree_dir" ]; then
  echo "Subtree directory $tree_dir doesn't exist, cannot delete it"
  exit 1
fi

# clean subtree branch
git stash

echo "Deleting WordPress subtree $tree_dir to the tag/ref $ref"

FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --index-filter "git rm --cached --ignore-unmatch -rf $tree_dir" --prune-empty -f HEAD

