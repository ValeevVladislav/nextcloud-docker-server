#!/usr/bin/env bash

set -euo pipefail

# Docker Compose configuration
COMPOSE_ARGS=(-f compose.yaml)

if [[ "${TEST_MODE:-false}" == "true" ]]; then
    COMPOSE_ARGS+=(-f compose.test.yaml)
fi

compose() {
    sudo docker compose "${COMPOSE_ARGS[@]}" "$@"
}

# Backup paths
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DESTINATION="${BACKUP_DIR}/${TIMESTAMP}"

# Check required services
if ! compose ps --status running --services | grep -q "^db$"; then
    echo "ERROR: MariaDB service is not running."
    exit 1
fi

if ! compose ps --status running --services | grep -q "^app$"; then
    echo "ERROR: Nextcloud service is not running."
    exit 1
fi

# Get MariaDB container ID dynamically
DB_CONTAINER=$(compose ps -q db)

if [[ -z "$DB_CONTAINER" ]]; then
    echo "ERROR: Could not determine MariaDB container ID."
    exit 1
fi

echo "Starting Nextcloud backup..."
echo "Backup destination: ${DESTINATION}"

mkdir -p "${DESTINATION}"

# Create MariaDB dump
echo "Creating MariaDB dump..."

sudo docker exec "$DB_CONTAINER" \
    sh -c 'mariadb-dump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' \
    > "${DESTINATION}/database.sql"

echo "MariaDB backup completed."

# Get Nextcloud container ID dynamically
APP_CONTAINER=$(compose ps -q app)

if [[ -z "$APP_CONTAINER" ]]; then
    echo "ERROR: Could not determine Nextcloud container ID."
    exit 1
fi

# Create Nextcloud data archive
echo "Creating Nextcloud data archive..."

sudo docker exec "$APP_CONTAINER" \
    tar -czf - -C /var/www/html . \
    > "${DESTINATION}/nextcloud-data.tar.gz"

echo "Nextcloud data backup completed."


echo "Backup completed successfully."
