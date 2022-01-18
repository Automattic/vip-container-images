# WordPress Container Images

## Adding Releases

To add a new WordPress release, run the following command on your local machine (Docker is **not** required):

```bash
cd vip-container-images # parent folder
./wordpress/add-version.sh x.y.z x.y.z
```

For WordPress 5.7.2:

```bash
cd vip-container-images # parent folder
./wordpress/add-version.sh 5.7.2 5.7.2
```

## Updating Releases

To update a relase, use the update script.

```bash
cd vip-container-images # parent folder
./wordpress/add-version.sh x.y.z
```

## Deleting Releases

To delete a relase, use the update script.

```bash
cd vip-container-images # parent folder
./wordpress/delete-version.sh x.y.z
```
