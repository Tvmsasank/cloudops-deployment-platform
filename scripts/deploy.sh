#!/usr/bin/env bash

set -euo pipefail

APP_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../app" && pwd)"
DEPLOY_DIR="/var/www/cloudops"
BACKUP_ROOT="/var/backups/cloudops"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

echo "======================================"
echo " CloudOps Deployment"
echo "======================================"

echo "Application source : $APP_SOURCE"
echo "Deployment directory: $DEPLOY_DIR"
echo "Backup directory    : $BACKUP_DIR"

echo ""
echo "[1/6] Creating backup directory..."

sudo mkdir -p "$BACKUP_DIR"

echo ""
echo "[2/6] Backing up current application..."

if [ -d "$DEPLOY_DIR" ] && [ "$(ls -A "$DEPLOY_DIR")" ]; then
    sudo cp -a "$DEPLOY_DIR/." "$BACKUP_DIR/"
    echo "Backup created successfully."
else
    echo "No existing application found. Skipping backup."
fi

echo ""
echo "[3/6] Deploying new application..."

sudo mkdir -p "$DEPLOY_DIR"

sudo rm -rf "$DEPLOY_DIR"/*

sudo cp -a "$APP_SOURCE/." "$DEPLOY_DIR/"

echo "Application copied successfully."

echo ""
echo "[4/6] Setting permissions..."

sudo chown -R root:root "$DEPLOY_DIR"

sudo find "$DEPLOY_DIR" -type d -exec chmod 755 {} \;
sudo find "$DEPLOY_DIR" -type f -exec chmod 644 {} \;

echo "Permissions configured."

echo ""
echo "[5/6] Validating Nginx configuration..."

sudo nginx -t

echo "Reloading Nginx..."

sudo systemctl reload nginx

echo ""
echo "[6/6] Running health check..."

if curl -fsS http://localhost/ > /dev/null; then
    echo "Health check PASSED."
else
    echo "Health check FAILED."
    exit 1
fi

echo ""
echo "======================================"
echo " Deployment successful"
echo "======================================"

echo "Deployment time : $TIMESTAMP"
echo "Backup location: $BACKUP_DIR"
