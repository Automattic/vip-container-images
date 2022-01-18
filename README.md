# VIP Container Images

This repository is used to build Docker container images used, among others, by the [VIP Local Development Environment](https://docs.wpvip.com/technical-references/vip-local-development-environment/).

Images are built and published using GitHub Actions and GitHub Packages. All images in this repository are [multi-architechture images](https://docs.docker.com/desktop/multi-arch/), supporting `amd64` and `arm64`.

## Using the images

You can find the most up to date versions of the images and the command to pull them in the sidebar, under the _Packages_ section. TL;DR the pulling has to be prefixed with `ghcr.io/automattic/vip-container-images`. For instance:

```bash
docker pull ghcr.io/automattic/vip-container-images/alpine:3.14.1
```

### Using image locally in dev-env

The easiest way is to reconfigure lando file in specific `dev-env` to build image directly from this repository.
For example for `dev-tools` you could do something like this:

```
services:

  devtools:
    type: compose
    services:
      build:
        context: ~/git/automattic/vip-container-images
        dockerfile: ~/git/automattic/vip-container-images/dev-tools/Dockerfile
      command: sleep infinity
      volumes:
        - devtools:/dev-tools
    volumes:
      devtools: {}
```

Note: Lando will try to pull image from remote repository if you would use `image` instead of `build` which would probably fail if your image is only local one.

## Publishing the images

The image publishing process is performed by [a GitHub action](.github/workflows/) every time a commit is done to `master`. All workflows are triggered then, therefore, all images are built in parallel.

## Updating Docker images

This repository has Dependabot [set up](.github/dependabot.yml). Whenever a Docker base image has a new available version, the bot will open a Pull Request with the change.

## Adding, Updating, and Removing Subtrees
There are scripts that can be used to add, update and remove WordPress version subtrees. Interface with these scripts in the following ways:

`$> wordpress/add-version.sh 5.9.1 5.9.1`
  This can be used to add a new WordPress version. The second parameter is a tag for the github repository. Alternatively you can use a commit hash.

`$> wordpress/update-version.sh 5.9.1`
  This can be used to update a version to its most recent tag/commit.

`$> wordpress/delete-version.sh 5.9.1`
  This can be used to delete a subtree.
