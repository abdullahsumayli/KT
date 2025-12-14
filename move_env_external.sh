#!/bin/bash
set -e

# Create secure directory
mkdir -p /etc/souqmatbakh

# Move .env to system location
cp -f /var/www/souqmatbakh/backend/.env /etc/souqmatbakh/backend.env
chown root:root /etc/souqmatbakh/backend.env
chmod 600 /etc/souqmatbakh/backend.env

# Update systemd service to use external env file
if grep -q "^EnvironmentFile=" /etc/systemd/system/souqmatbakh-backend.service; then
    sed -i "s#^EnvironmentFile=.*#EnvironmentFile=/etc/souqmatbakh/backend.env#" /etc/systemd/system/souqmatbakh-backend.service
else
    sed -i "/^\[Service\]/a EnvironmentFile=/etc/souqmatbakh/backend.env" /etc/systemd/system/souqmatbakh-backend.service
fi

# Reload and restart
systemctl daemon-reload
systemctl restart souqmatbakh-backend
sleep 2

# Verify
if curl -fsS https://souqmatbakh.com/api/ >/dev/null; then
    echo "✅ .env Moved Successfully to /etc/souqmatbakh/backend.env"
    echo "📁 Old location: /var/www/souqmatbakh/backend/.env (kept as backup)"
    echo "📁 New location: /etc/souqmatbakh/backend.env"
else
    echo "❌ API Check Failed"
    exit 1
fi
