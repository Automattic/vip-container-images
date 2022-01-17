#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Syntax: patch-version.sh <version> <gitref>"
  echo "  <version>  Name of the version as we are going to reference it in VIP"
  echo "  <gitref>   Changeset/tag to import from the WordPress git repository"
  echo
  echo "Examples:"
  echo "$ patch-version.sh 5.9.1"
  exit 1
fi

version=$1
tree_dir="wordpress/public/${version}"
extra_dir="wordpress/public/extra"
cwd=$(pwd)

echo
echo "====================================="
echo "Copying extra files for VIP"
echo "====================================="
echo
# shellcheck disable=SC2164
cd extra_dir
cp -a . $tree_dir
# shellcheck disable=SC2162
find . -type f | while read f; do git add "$tree_dir/$f"; done
cd $cwd

echo
echo "====================================="
echo "Adding GitHub Action"
echo "====================================="
echo

cat <<EOT >> .github/workflows/wordpress.yml
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

echo
echo "====================================="
echo "Final status"
echo "====================================="
echo
git status

echo "Review changes and commit when they are ready. Image will be built and published by GitHub on commit."
