#!/bin/sh

export XDEBUG_MODE=off

if [ -t 1 ]; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  CYAN=$(tput setaf 6)
  STRONG=$(tput bold)
  CODE=$(tput smso)
  ENDCODE=$(tput rmso)
  RESET=$(tput sgr0)
else
  RED=""
  GREEN=""
  YELLOW=""
  CYAN=""
  STRONG=""
  CODE='`'
  ENDCODE='`'
  RESET=""
fi

subdomain=0

# Check if the first argument starts with '--'
if [ "${1#--}" != "$1" ]; then
  if [ $# -lt 8 ]; then
    echo "${YELLOW}${STRONG}Syntax:${RESET} setup.sh --host <db_host> --user <db_admin_user> --domain <wp_domain> --title <wp_title> [--ms-domain <multisite_domain>] [--subdomain] [--wpadmin_password <password>]"
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
      --wpadmin_password)
        wpadmin_password="$2"
        shift 2
        ;;
      *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
  done
else
  if [ $# -lt 4 ]; then
    echo "${YELLOW}${STRONG}Syntax:${RESET} setup.sh <db_host> <db_admin_user> <wp_domain> <wp_title> [<multisite_domain>] [<subdomain>]"
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

wpadmin_password="${wpadmin_password:-password}"

# Make sure to check the core files are there before trying to install WordPress.
echo "Waiting for WordPress core files to be copied"
i=0;
while [ ! -f /wp/wp-includes/pomo/mo.php ]
do
  printf "."
  sleep 0.5
  i=$((i+1))
  # Roughly 2 minutes
  if [ $i -eq 120 ]; then
    echo "${RED}${STRONG}ERROR:${RESET} Failed to copy WordPress core files in time. Please try to restart the environment."
    exit 1;
  fi
done

if [ -n "${LANDO_INFO}" ] && [ "$(echo "${LANDO_INFO}" | jq -r '.["vip-mu-plugins"]')" != 'null' ]; then
  echo "${CYAN}Waiting for MU-plugins to be copied${RESET}"
  i=0;
  while [ ! -f /wp/wp-content/mu-plugins/.version ]; do
    printf "."
    sleep 1
    i=$((i+1))
    if [ $i -eq 120 ]; then
      echo "${RED}${STRONG}ERROR:${RESET} Failed to copy MU-plugins in time. Please try to restart the environment."
      exit 1;
    fi
  done
fi

if [ -r /wp/config/wp-config.php ]; then
  echo "${GREEN}wp-config.php already exists${RESET}"
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

printf "%sWaiting for MySQL to come online%s" "${CYAN}" "${RESET}"
second=0
while ! mysqladmin ping -h "${db_host}" --silent && [ "${second}" -lt 120 ]; do
  printf "."
  sleep 1
  second=$((second+1))
done
echo ""
if ! mysqladmin ping -h "${db_host}" --silent; then
    echo "${RED}${STRONG}ERROR:${RESET} MySQL has failed to come online. Please check the database container logs for details."
    exit 1;
fi

{
  echo "CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED BY 'wordpress';"
  echo "CREATE USER IF NOT EXISTS 'netapp'@'%' IDENTIFIED BY 'wordpress';"
  echo "GRANT ALL ON wordpress.* TO 'wordpress'@'%';"
  echo "GRANT ALL ON wordpress_test.* TO 'wordpress'@'%';"
  echo "GRANT ALL ON wordpress.* TO 'netapp'@'%';"
  echo "GRANT SET_ANY_DEFINER ON *.* TO 'wordpress'@'%';"
  echo "CREATE DATABASE IF NOT EXISTS wordpress;"
  echo "CREATE DATABASE IF NOT EXISTS wordpress_test;"
} | mysql -h "$db_host" -u "$db_admin_user"

echo "${CYAN}Copying dev-env-plugin.php to mu-plugins${RESET}"
cp /dev-tools/dev-env-plugin.php /wp/wp-content/mu-plugins/

if [ -n "${ENABLE_ELASTICSEARCH}" ] || { [ -n "${LANDO_INFO}" ] && [ "$(echo "${LANDO_INFO}" | jq .elasticsearch.service)" != 'null' ]; }; then
  printf "%sWaiting for Elasticsearch to come online%s" "${CYAN}" "${RESET}"
  second=0
  while ! curl -s 'http://elasticsearch:9200/_cluster/health' > /dev/null && [ "${second}" -lt 60 ]; do
    printf "."
    sleep 1
    second=$((second+1))
  done
  echo ""
  status="$(curl -s 'http://elasticsearch:9200/_cluster/health?wait_for_status=yellow&timeout=60s' | jq -r .status)"
  if [ "${status}" != 'green' ] && [ "${status}" != 'yellow' ]; then
      echo "${YELLOW}${STRONG}WARNING:${RESET} Elasticsearch has failed to come online"
      curl -sS 'http://elasticsearch:9200/_cluster/health'
  fi
fi

echo "${CYAN}Checking for WordPress installation...${RESET}"

wp cache flush --skip-plugins --skip-themes
if ! wp core is-installed --skip-plugins --skip-themes; then
  echo "${CYAN}No installation found, installing WordPress...${RESET}"

  # Ensuring wp-config-defaults is up to date
  cp /dev-tools/wp-config-defaults.php /wp/config/

  if [ -n "$multisite_domain" ]; then
    # shellcheck disable=SC2046
    wp core multisite-install \
      --path=/wp \
      --url="$wp_url" \
      --title="$wp_title" \
      --admin_user="vipgo" \
      --admin_email="vip@localhost.local" \
      --admin_password="$wpadmin_password" \
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
      --admin_password="$wpadmin_password" \
      --skip-email \
      --skip-themes \
      --skip-plugins #2>/dev/null
  fi

  if [ -n "${LANDO_INFO}" ] && [ "$(echo "${LANDO_INFO}" | jq .elasticsearch.service)" != 'null' ] && [ "$(echo "${LANDO_INFO}" | jq '.["demo-app-code"].service')" != 'null' ]; then
    wp config set VIP_ENABLE_VIP_SEARCH true --raw
    wp config set VIP_ENABLE_VIP_SEARCH_QUERY_INTEGRATION true --raw
    echo "Automatically set constants ${CODE}VIP_ENABLE_VIP_SEARCH${ENDCODE} and ${CODE}VIP_ENABLE_VIP_SEARCH_QUERY_INTEGRATION${ENDCODE} to ${CODE}true${ENDCODE}. For more information, see https://docs.wpvip.com/how-tos/vip-search/enable/"
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
else
  echo "${GREEN}WordPress already installed${RESET}"
fi

echo "${CYAN}Processing environment variables${RESET}"
for var in $(wp config list VIP_ENV_VAR_ --fields=name --format=csv | tail -n +2); do
  wp config delete "${var}" --quiet
done

if env | grep -qE '^VIP_ENV_VAR_'; then
  # shellcheck disable=SC2016 # no variable expansion is meant here
  wp eval 'foreach (get_defined_constants() as $k => $_) if (str_starts_with($k, "VIP_ENV_VAR_")) exit(100); exit(0);' > /dev/null 2>&1
  if [ $? -eq 100 ]; then
    # shellcheck disable=SC2016 # no variable expansion is meant here
    echo "${YELLOW}${STRONG}WARNING:${RESET} ${CODE}VIP_ENV_VAR_${ENDCODE} constants have been detected in the code. Please remove them, as the system handles them automatically now."
    php /dev-tools/backfill-env-vars.php
  else
    for var in $(env | grep -E '^VIP_ENV_VAR_'); do
      key=$(echo "${var}" | cut -d= -f1)
      value=$(echo "${var}" | cut -d= -f2-)
      wp config set --quiet "${key}" "${value}"
    done
  fi
fi
