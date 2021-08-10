# WordPress Container Images

## Adding Releases

To add a new WordPress release, run the following command on your local machine (Docker is **not** required):

```bash
cd vip-container-images # parent folder
sh add-version.sh x.y.z x.y.z
```

For WordPress 5.7.2:

```bash
cd vip-container-images # parent folder
sh add-version.sh 5.7.2 5.7.2
```

## Updating Releases

To update a relase, perform the changes on the necessary files and then commit the changes to `master`.
