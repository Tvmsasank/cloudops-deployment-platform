#!/usr/bin/env bash

set -euo pipefail

DEPLOY_DIR="/var/www/cloudops"

echo "======================================"
echo " CloudOps CodeDeploy Deployment"
echo "======================================"

echo ""
echo "[1/4] Setting application permissions..."

sudo chown -R root:root "$DEPLOY_DIR"

sudo find "$DEPLOY_DIR" -type d -exec chmod 755 {} \;
sudo find "$DEPLOY_DIR" -type f -exec chmod 644 {} \;

echo "Permissions configured."

echo ""
echo "[2/4] Validating Nginx configuration..."

sudo nginx -t

echo "Nginx configuration valid."

echo ""
echo "[3/4] Reloading Nginx..."

sudo systemctl reload nginx

echo "Nginx reloaded."

echo ""
echo "[4/4] Running application health check..."

if curl -fsS http://localhost/ > /dev/null; then
    echo "Health check PASSED."
else
    echo "Health check FAILED."
    exit 1
fi

echo ""
echo "======================================"
echo " CodeDeploy deployment successful"
echo "======================================"
