# WordPress Container Images

This repo is used to build WordPress container images used by the [VIP Local Development Environment](https://docs.wpvip.com/technical-references/vip-local-development-environment/).

Images are built and published using GitHub Actions and GitHub Packages.

## Adding Releases

To add a new WordPress release, run the following command on your local machine (Docker is **not** required):

```bash
sh add-version.sh x.y.z x.y.z
```

For WordPress 5.7.2:

```bash
sh add-version.sh 5.7.2 5.7.2
```

## Updating Releases

To update a relase, perform the changes on the necessary files and then commit the changes to `trunk`.

## Publishing Images

The image publishing process is performed by [a GitHub action](.github/workflows/publish.yml) every time a commit is done to `trunk`.
