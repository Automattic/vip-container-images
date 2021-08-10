# VIP Container Images

This repository is used to build Docker container images used, among others, by the [VIP Local Development Environment](https://docs.wpvip.com/technical-references/vip-local-development-environment/).

Images are built and published using GitHub Actions and GitHub Packages.

## Using the images

You can find the most up to date versions of the images and the command to pull them in the sidebar, under the _Packages_ section. TL;DR the pulling has to be prefixed with `ghcr.io/automattic/vip-container-images`. For instance:

```bash
docker pull ghcr.io/automattic/vip-container-images/alpine:3.14.1
```

## Publishing the images

The image publishing process is performed by [a GitHub action](.github/workflows/) every time a commit is done to `master`. All workflows are triggered then, therefore, all images are built in parallel.

## Updating Docker images

This repository has Dependabot [set up](.github/dependabot.yml). Whenever a Docker base image has a new available version, the bot will open a Pull Request with the change.
