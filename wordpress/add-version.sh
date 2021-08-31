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

echo
echo "====================================="
echo "Creating subtree public/$version"
echo "====================================="
echo
git subtree add -P wordpress/public/$version https://github.com/WordPress/WordPress $ref --squash -m "Add public WordPress $version"

echo
echo "====================================="
echo "Copying extra files for VIP"
echo "====================================="
echo
cd wordpress/public/extra
cp -a . ../$version/
find . -type f | while read f; do git add ../$version/$f; done
cd ../../..

echo
echo "====================================="
echo "Patching files for VIP"
echo "====================================="
echo
cd wordpress/public/$version
for p in ../patches/*.patch; do patch -p1 -s < $p; done
cd ../../..

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
          push: ${{ github.base_ref == null }}
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
