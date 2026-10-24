#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <backup-directory>"
    exit 1
fi

RESTORE_POINT="$1"

if [[ ! -d "$RESTORE_POINT" ]]; then
    echo "ERROR: Backup directory not found: $RESTORE_POINT"
    exit 1
fi

if [[ ! -s "$RESTORE_POINT/database.sql" ]]; then
    echo "ERROR: database.sql is missing or empty."
    exit 1
fi

if [[ ! -s "$RESTORE_POINT/nextcloud-data.tar.gz" ]]; then
    echo "ERROR: nextcloud-data.tar.gz is missing or empty."
    exit 1
fi

COMPOSE_ARGS=(-f compose.yaml)

if [[ "${TEST_MODE:-false}" == "true" ]]; then
    COMPOSE_ARGS+=(-f compose.test.yaml)
fi

compose() {
    sudo docker compose "${COMPOSE_ARGS[@]}" "$@"
}

if ! compose ps --status running --services | grep -q "^db$"; then
    echo "ERROR: MariaDB service is not running."
    exit 1
fi

if ! compose ps --status running --services | grep -q "^app$"; then
    echo "ERROR: Nextcloud service is not running."
    exit 1
fi

DB_CONTAINER=$(compose ps -q db)
APP_CONTAINER=$(compose ps -q app)

if [[ -z "$DB_CONTAINER" ]]; then
    echo "ERROR: Could not determine MariaDB container ID."
    exit 1
fi

if [[ -z "$APP_CONTAINER" ]]; then
    echo "ERROR: Could not determine Nextcloud container ID."
    exit 1
fi

echo "Starting Nextcloud restore..."
echo "Restore source: $RESTORE_POINT"

echo "Checking Nextcloud archive..."
gzip -t "$RESTORE_POINT/nextcloud-data.tar.gz"

echo "Restoring MariaDB database..."

sudo docker exec -i "$DB_CONTAINER" \
    sh -c 'mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' \
    < "$RESTORE_POINT/database.sql"

echo "MariaDB restore completed."

echo "Restoring Nextcloud files..."

cat "$RESTORE_POINT/nextcloud-data.tar.gz" | \
sudo docker exec -i "$APP_CONTAINER" \
    tar -xzf - -C /var/www/html

echo "Nextcloud files restore completed."
echo "Restore completed successfully."
