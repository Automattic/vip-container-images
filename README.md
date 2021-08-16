# VIP Container Images

This repository is used to build Docker container images used, among others, by the [VIP Local Development Environment](https://docs.wpvip.com/technical-references/vip-local-development-environment/).

Images are built and published using GitHub Actions and GitHub Packages.

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

