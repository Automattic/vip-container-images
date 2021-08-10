#!/bin/bash

syntax() {
  echo "Syntax: add-site.sh --slug=<slug> --title=\"<title>\""
  exit 1
}

# Parse title and slug arguments
arguments=`getopt -o '' -l slug:,title: -- "$@"`
eval set -- "$arguments"
while true; do
    case "$1" in
    --slug) slug=$2; shift 2;;
    --title) title=$2; shift 2;;
    --) shift; break;;
    esac
done
[ -z "$slug" ] && echo "ERROR: Missing or empty slug argument" && syntax
[ -z "$title" ] && echo "ERROR: Missing or empty title argument" && syntax

network_domain=`wp --allow-root site list --field=domain | head -n1`

site_domain=$slug.$network_domain

echo "Checking if this is a multisite installation..."
wp --allow-root core is-installed --network
[ $? -ne 0 ] && echo "ERROR: Not a multisite' first" && exit 1

echo "Checking if $site_domain already belongs to another site..."
wp --allow-root --path=/wp site list --field=domain | grep -q "^$site_domain$"
[ $? -eq 0 ] && echo "ERROR: site with domain $site_domain already exists" && exit 1

echo "Creating the new site..."
wp --allow-root --path=/wp site create --title="$title" --slug="$slug"

echo
echo "======================================================================"
echo "Site '$title' added correctly"
echo
echo "You can access it using these URLs:"
echo "  http://$site_domain/"
echo "  http://$site_domain/wp-admin/"
echo "======================================================================"
