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
read -r -d '' action_str <<'EOT'
      - name: Build ${version} container image
        uses: docker/build-push-action@v2
        with:
          file: wordpress/Dockerfile
          platforms: linux/amd64,linux/arm64
          context: wordpress/public/${version}
          # base_ref is only defined in PRs, hence we're only pushing when we're not in a PR
          push: \${{ github.base_ref == null }}
          tags: |
            ghcr.io/automattic/vip-container-images/wordpress:${version}
EOT

tree_dir="wordpress/public/${version}"
if [ ! -d "$tree_dir" ]; then
  echo "Subtree directory $tree_dir doesn't exist, cannot delete it"
  exit 1
fi

# clean subtree branch
git stash

echo "Deleting WordPress subtree $tree_dir to the tag/ref $ref"

FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --index-filter "git rm --cached --ignore-unmatch -rf $tree_dir" --prune-empty -f HEAD

# clean workflow manifest
sed -i "s/$action_str//g" .github/workflows/wordpress.yml