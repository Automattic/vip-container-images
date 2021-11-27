#!/bin/sh

DB_USER="${1:-${MYSQL_USER}}"
DB_PASSWORD="${2:-${MYSQL_PASSWORD}}"
DB_NAME="${3:-${MYSQL_DB}}"
DB_HOST="${4:-${MYSQL_HOST}}"

echo "Waiting for MySQL..."
while ! nc -z "${DB_HOST}" 3306; do
	sleep 1
done

mysqladmin create "${DB_NAME}" --user="${DB_USER}" --password="${DB_PASSWORD}" --host="${DB_HOST}" || true
