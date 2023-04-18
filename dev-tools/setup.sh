#!/bin/sh

subdomain=0

# Check if the first argument starts with '--'
if [ "${1#--}" != "$1" ]; then
  if [ $# -lt 8 ]; then
    echo "Syntax: setup.sh --host <db_host> --user <db_admin_user> --domain <wp_domain> --title <wp_title> [--ms-domain <multisite_domain>] [--subdomain]"
    exit 1
  fi

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --host)
        db_host="$2"
        shift 2
        ;;
      --user)
        db_admin_user="$2"
        shift 2
        ;;
      --domain)
        wp_url="$2"
        shift 2
        ;;
      --title)
        wp_title="$2"
        shift 2
        ;;
      --ms-domain)
        multisite_domain="$2"
        shift 2
        ;;
      --subdomain)
        subdomain=1
        shift 1
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  done
else
  if [ $# -lt 4 ]; then
    echo "Syntax: setup.sh <db_host> <db_admin_user> <wp_domain> <wp_title> [<multisite_domain>] [<subdomain>]"
    exit 1
  fi

  db_host=$1
  db_admin_user=$2
  wp_url=$3
  wp_title=$4
  multisite_domain=$5

  if [ -n "$6" ]; then
    subdomain=1
  fi
fi

# Make sure to check the core files are there before trying to install WordPress.
echo "Waiting for core files to be copied"
i=0;
while [ ! -f /wp/wp-includes/pomo/mo.php ]
do
  sleep 0.5
  i=$((i+1))
  # Roughly 1 minute
  if [ $i -eq 120 ]; then
    echo "ERROR: WordPress core files not found. Please try to restart or destroy the environment"
    exit 1;
  fi
done

if mountpoint -q /wp/wp-content/mu-plugins; then
  echo 'Waiting for mu-plugins...'
  i=0;
  while [ ! -f /wp/wp-content/mu-plugins/.version ]; do
    sleep 1
    i=$((i+1))
    if [ $i -eq 60 ]; then
      echo "ERROR: mu-plugins not found. Please try to restart or destroy the environment"
      exit 1;
    fi
  done
fi

if [ -r /wp/config/wp-config.php ]; then
  echo "Already existing wp-config.php file"
else
  cp /dev-tools/wp-config-defaults.php /wp/config/
  sed -e "s/%DB_HOST%/$db_host/" /dev-tools/wp-config.php.tpl > /wp/config/wp-config.php
  if [ -n "$multisite_domain" ]; then
    sed -e "s/%DOMAIN%/$multisite_domain/" /dev-tools/wp-config-multisite.php.tpl >> /wp/config/wp-config.php
    if [ "$subdomain" -eq 0 ]; then
      sed -i "s/define( 'SUBDOMAIN_INSTALL', true );/define( 'SUBDOMAIN_INSTALL', false );/" /wp/config/wp-config.php
    fi
  fi
  curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /wp/config/wp-config.php
fi

echo "Waiting for MySQL to come online..."
second=0
while ! mysqladmin ping -h "${db_host}" --silent && [ "${second}" -lt 60 ]; do
  sleep 1
  second=$((second+1))
done
if ! mysqladmin ping -h "${db_host}" --silent; then
    echo "ERROR: mysql has failed to come online"
    exit 1;
fi

echo "Checking for database connectivity..."
if ! mysql -h "$db_host" -u wordpress -pwordpress wordpress -e "SELECT 'testing_db'" >/dev/null 2>&1; then
  echo "No WordPress database exists, provisioning..."
  echo "CREATE USER IF NOT EXISTS 'wordpress'@'localhost' IDENTIFIED BY 'wordpress'" | mysql -h "$db_host" -u "$db_admin_user"
  echo "CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED BY 'wordpress'" | mysql -h "$db_host" -u "$db_admin_user"
  echo "GRANT ALL ON *.* TO 'wordpress'@'localhost' WITH GRANT OPTION;" | mysql -h "$db_host" -u "$db_admin_user"
  echo "GRANT ALL ON *.* TO 'wordpress'@'%' WITH GRANT OPTION;" | mysql -h "$db_host" -u "$db_admin_user"
  echo "CREATE DATABASE IF NOT EXISTS wordpress;" | mysql -h "$db_host" -u "$db_admin_user"
fi

echo "Copying dev-env-plugin.php to mu-plugins"
cp /dev-tools/dev-env-plugin.php /wp/wp-content/mu-plugins/

if [ -n "${ENABLE_ELASTICSEARCH}" ] || { [ -n "${LANDO_INFO}" ] && [ "$(echo "${LANDO_INFO}" | jq .elasticsearch.service)" != 'null' ]; }; then
  echo "Waiting for Elasticsearch to come online..."
  status="$(curl -s 'http://elasticsearch:9200/_cluster/health?wait_for_status=yellow&timeout=60s' | jq -r .status)"
  if [ "${status}" != 'green' ] && [ "${status}" != 'yellow' ]; then
      echo "WARNING: Elasticsearch has failed to come online"
  fi
fi

echo "Checking for WordPress installation..."

site_exist_check_output=$(wp option get siteurl 2>&1);

site_exist_return_value=$?;
if echo "$site_exist_check_output" | grep -Eq "(Site .* not found)|(The site you have requested is not installed)"; then
  echo "No installation found, installing WordPress..."

  # Ensuring wp-config-defaults is up to date
  cp /dev-tools/wp-config-defaults.php /wp/config/

  if [ -n "$multisite_domain" ]; then
    wp core multisite-install \
      --path=/wp \
      --url="$wp_url" \
      --title="$wp_title" \
      --admin_user="vipgo" \
      --admin_email="vip@localhost.local" \
      --admin_password="password" \
      --skip-email \
      --skip-themes \
      --skip-plugins \
      --skip-config \
      $(if [ "$subdomain" -eq 1 ]; then echo "--subdomains"; fi) #2>/dev/null
  else
    wp core install \
      --path=/wp \
      --url="$wp_url" \
      --title="$wp_title" \
      --admin_user="vipgo" \
      --admin_email="vip@localhost.local" \
      --admin_password="password" \
      --skip-email \
      --skip-themes \
      --skip-plugins #2>/dev/null
  fi

  if [ -n "${LANDO_INFO}" ] && [ "$(echo "${LANDO_INFO}" | jq .elasticsearch.service)" != 'null' ] && [ "$(echo "${LANDO_INFO}" | jq '.["demo-app-code"].service')" != 'null' ]; then
    wp config set VIP_ENABLE_VIP_SEARCH true --raw
    wp config set VIP_ENABLE_VIP_SEARCH_QUERY_INTEGRATION true --raw
    echo "Automatically set constants VIP_ENABLE_VIP_SEARCH and VIP_ENABLE_VIP_SEARCH_QUERY_INTEGRATION to true. For more information, see https://docs.wpvip.com/how-tos/vip-search/enable/"
    echo "To disable the Enterprise Search integration, please run:"
    if [ -n "${LANDO_APP_NAME}" ]; then
      echo "vip dev-env exec --slug ${LANDO_APP_NAME} -- wp config delete VIP_ENABLE_VIP_SEARCH"
      echo "vip dev-env exec --slug ${LANDO_APP_NAME} -- wp config delete VIP_ENABLE_VIP_SEARCH_QUERY_INTEGRATION"
    else
      echo "wp config delete VIP_ENABLE_VIP_SEARCH"
      echo "wp config delete VIP_ENABLE_VIP_SEARCH_QUERY_INTEGRATION"
    fi
  fi

  if wp cli has-command vip-search; then
    wp vip-search index --skip-confirm --setup
  fi

  wp user add-cap 1 view_query_monitor
elif [ "$site_exist_return_value" != 0 ] ; then
  echo "ERROR: Could not find out if site exists."
  echo "$site_exist_check_output"
else
  echo "WordPress already installed"
fi
