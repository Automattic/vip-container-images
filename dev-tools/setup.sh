#!/bin/sh

if [ $# -lt 4 ]; then
  echo: "Syntax: setup.sh <db_host> <db_admin_user> <wp_domain> <wp_title> [<multisite_domain>]"
  exit 1
fi

db_host=$1
db_admin_user=$2
wp_url=$3
wp_title=$4
multisite_domain=$5

if [ -r /wp/config/wp-config.php ]; then
  echo "Already existing wp-config.php file"
else
  cp /dev-tools/wp-config-defaults.php /wp/config/
  cat /dev-tools/wp-config.php.tpl | sed -e "s/%DB_HOST%/$db_host/" > /wp/config/wp-config.php
  if [ -n "$multisite_domain" ]; then
    cat /dev-tools/wp-config-multisite.php.tpl | sed -e "s/%DOMAIN%/$multisite_domain/" >> /wp/config/wp-config.php
  fi
  curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /wp/config/wp-config.php
fi

echo "Checking for database connectivity..."
echo "SELECT 'testing_db'"  | mysql -h $db_host -u wordpress -pwordpress wordpress
if [ $? -ne 0 ]; then
  echo "No WordPress database exists, provisioning..."
  echo "GRANT ALL ON *.* TO 'wordpress'@'localhost' IDENTIFIED BY 'wordpress' WITH GRANT OPTION;" | mysql -h $db_host -u root
  echo "GRANT ALL ON *.* TO 'wordpress'@'%' IDENTIFIED BY 'wordpress' WITH GRANT OPTION;" | mysql -h $db_host -u $db_admin_user
  echo "CREATE DATABASE wordpress;" | mysql -h $db_host -u $db_admin_user
fi

echo "Checking for WordPress installation..."
wp --allow-root option get siteurl
if [ $? -ne 0 ]; then
  echo "No installation found, installing WordPress..."
  if [ -n "$multisite_domain" ]; then
    wp core multisite-install \
      --path=/wp \
      --allow-root \
      --url="$wp_url" \
      --title="$wp_title" \
      --admin_user="vipgo" \
      --admin_email="vip@localhost.local" \
      --admin_password="password" \
      --skip-email \
      --skip-plugins \
      --subdomains \
      --skip-config #2>/dev/null
  else
    wp core install \
      --path=/wp \
      --allow-root \
      --url="$wp_url" \
      --title="$wp_title" \
      --admin_user="vipgo" \
      --admin_email="vip@localhost.local" \
      --admin_password="password" \
      --skip-email \
      --skip-plugins #2>/dev/null
  fi

  wp --allow-root elasticpress delete-index
  wp --allow-root elasticpress index --setup

  wp --allow-root user add-cap 1 view_query_monitor
fi
